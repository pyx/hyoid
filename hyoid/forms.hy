;;; -*- coding: utf-8 -*-
;;; Copyright (c) 2016, Philip Xu <pyx@xrefactor.com>
;;; License: BSD New, see LICENSE for details.
"hyoid.forms - forms"

(import
  [flask-wtf [Form]]
  [wtforms.fields
    [BooleanField PasswordField StringField SubmitField TextAreaField]]
  [wtforms.fields.html5 [EmailField]]
  [wtforms.validators
    [Email EqualTo Length DataRequired]]
  [hyoid.models [User db]])

(require hyer.dsl)

(defclass EmailForm [Form]
  [[email
    (EmailField "Email"
                :validators [(DataRequired) (Email) (Length :max 120)])]])

(defclass PasswordForm [Form]
  [[password
    (PasswordField "Password" :validators [(DataRequired)])]])

(defclass ChangeEmailForm [EmailForm]
  [[submit (SubmitField "Change")]])

(defclass ChangeNameForm [Form]
  [[name
    (StringField "New Name" :validators [(DataRequired) (Length :max 120)])]
   [submit (SubmitField "Change")]])

(defclass ChangePasswordForm [PasswordForm]
  [[newpass (PasswordField "New Password" :validators [(DataRequired)])]
   [confirm (PasswordField "Confirm Password"
                           :validators [(DataRequired) (EqualTo "newpass")])]
   [submit (SubmitField "Change")]])

(defclass SignInForm [EmailForm PasswordForm]
  [[remember-me (BooleanField "Remember Me")]
   [submit (SubmitField "Sign In")]])

(defclass NewPostForm [Form]
  [[content (TextAreaField "New Message" :validators [(DataRequired)])]
   [submit (SubmitField "Post")]])

(defclass UpdatePostForm [Form]
  [[content (TextAreaField "Edit Message" :validators [(DataRequired)])]
   [submit (SubmitField "Update")]])

(defclass NewTopicForm [Form]
  [[title (StringField "New Topic"
                       :validators [(DataRequired) (Length :max 120)])]
   [content (TextAreaField "Content" :validators [(DataRequired)])]
   [submit (SubmitField "Submit")]])
