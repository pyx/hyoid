;;; -*- coding: utf-8 -*-
;;; Copyright (c) 2016, Philip Xu <pyx@xrefactor.com>
;;; License: BSD New, see LICENSE for details.
"hyoid.app - application factory"

(import
  [flask [redirect url-for]]
  [flask-gravatar [Gravatar]]
  [flask-moment [Moment]]
  [flask-pure [Pure]]
  [hyer.dsl [config-from-pyfile register-blueprint]]
  [hyoid.user [user init-app :as user-init]]
  [hyoid.forum [forum]]
  [hyoid.models [init-app :as models-init]]
)

(require hyer.dsl)

(defn create-app [config-filename]
  (defapplication app [:instance-relative-config true]
    (GET index "/" (redirect (url-for 'user.login)))
    (config-from-pyfile config-filename :silent true)
    models-init
    user-init
    Moment
    Pure
    (register-blueprint user :url-prefix '/u)
    (register-blueprint forum :url-prefix '/t)
    (Gravatar :default 'identicon)))
