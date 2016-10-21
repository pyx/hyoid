;;; -*- coding: utf-8 -*-
;;; Copyright (c) 2016, Philip Xu <pyx@xrefactor.com>
;;; License: BSD New, see LICENSE for details.
"hyoid.user - user blueprint"

(import
  [flask [flash render-template]]
  [flask-login
    [LoginManager current-user login-user logout-user]]
  [itsdangerous [URLSafeTimedSerializer]]
  [hyoid.forms
    [ChangeEmailForm ChangeNameForm ChangePasswordForm SignInForm]]
  [hyoid.models [User db]])

(require hyer.dsl)
(import-for-hyer-dsl)

(def login-manager (LoginManager))
(setv login-manager.login-view 'user.login)

(with-decorator login-manager.user-loader
  (defn load-user [user-id]
    (User.query.get (int user-id))))

(defn init-app [app]
  (login-manager.init-app app))

(defn check-password [user password]
  (and user user.active? (user.check-password password)))

(defn unique? [field data]
  (-> (User.query.filter
        (db.and- (field.like data)
                 (db.not- (= User.id current-user.id))))
    .first
    not))

(defmacro get-serializer []
  `(URLSafeTimedSerializer (get current-app.config "SECRET_KEY")))

(defblueprint user []
  (GET dashboard "/"
    (render-template "user/dashboard.html"))

  (GET/POST change-email "/change/email/" (login-required
    (process-form ChangeEmailForm "user/change_email.html"
      (if (unique? User.email form.email.data)
        (do
          (setv current-user.email form.email.data)
          (update-and-flash
            current-user "Email changed, sign in with this one next time")
          (redirect-to-next-or-view '.dashboard))
        (flash "This email is already taken")))))

  (GET/POST change-name "/change/name/" (login-required
    (process-form ChangeNameForm "user/change_name.html"
      (if (unique? User.name form.name.data)
        (do
          (setv current-user.name form.name.data)
          (update-and-flash current-user "User name changed")
          (redirect-to-next-or-view '.dashboard))
        (flash "This user name is already taken")))))

  (GET/POST change-password "/change/password/" (login-required
    (process-form ChangePasswordForm "user/change_password.html"
      (if (.check-password current-user form.password.data)
        (do
          (setattr current-user 'password form.newpass.data)
          (update-and-flash current-user "Password changed")
          (redirect-to-next-or-view '.dashboard))
        (flash "Incorrect password")))))

  (GET profile "/<int:id>/"
    (render-template "user/profile.html" :user (User.query.get-or-404 id)))

  (GET/POST login "/login/"
    (process-form SignInForm "user/login.html"
      (def user (.first (User.query.filter-by :email form.email.data)))
      (if (check-password user form.password.data)
        (do
          (login-user user form.remember-me.data)
          (flash "Signed in successfully.")
          (redirect-to-next-or-view '.dashboard))
        (flash "Invalid email or password"))))

  (GET logout "/logout/" (login-required
    (logout-user)
    (flash "Signed out.")
    (redirect-to-view '.login))))
