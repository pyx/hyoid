;;; -*- coding: utf-8 -*-
;;; Copyright (c) 2016, Philip Xu <pyx@xrefactor.com>
;;; License: BSD New, see LICENSE for details.
"hyoid.models - models of hyoid"

(import
  [datetime [datetime]]
  [bleach [linkify]]
  [flask [url-for]]
  [flask-login [UserMixin]]
  [flask-sqlalchemy [SQLAlchemy]]
  [markdown [markdown]]
  [werkzeug.security [check-password-hash generate-password-hash]])

(require hyer.dsl)

(def db (SQLAlchemy))

(defmacro column [name type &rest args]
  `[~name (db.Column ~type ~@args)])

(defclass CreatedOnMixin [object]
  [(column created-on db.DateTime :default datetime.utcnow)])

(defclass UpdatedOnMixin [object]
  [(column updated-on
           db.DateTime :default datetime.utcnow :onupdate datetime.utcnow)])

(defclass Post [CreatedOnMixin UpdatedOnMixin db.Model]
  [(column id db.Integer :primary-key true)
   (column content db.Text)
   (column content-html db.Text)
   (column author-id (db.ForeignKey "user.id") :index true)
   (column topic-id (db.ForeignKey "topic.id") :index true)
   [update-html
    (fn [self]
      (setv self.updated-on (datetime.utcnow))
      (setv self.content-html
        (->
          self.content
          (markdown :extensions
                    ["markdown.extensions.extra"
                     "markdown.extensions.admonition"
                     "markdown.extensions.codehilite"
                     "markdown.extensions.sane_lists"
                     "markdown.extensions.toc"
                     "markdown.extensions.wikilinks"])
          linkify)))]])

(defclass Topic [CreatedOnMixin UpdatedOnMixin db.Model]
  [(column id db.Integer :primary-key true)
   (column title (db.String 120))
   (column is-sticky db.Boolean :default false)
   (column author-id (db.ForeignKey "user.id") :index true)
   [posts
    (db.relationship
      "Post" :backref "topic" :cascade "all,delete"
      :lazy "dynamic" :order-by "Post.id")]
   [last-post (with-decorator property
                (fn [self] (get self.posts -1)))]
   [post-count (with-decorator property (fn [self] (self.posts.count)))]
   [url (with-decorator property
          (fn [self] (url-for 'forum.topic :id self.id)))]])

(defclass User [UserMixin CreatedOnMixin db.Model]
  [(column id db.Integer :primary-key true)
   (column email (db.String 120) :unique true)
   (column name (db.String 120) :unique true)
   (column password-hash (db.String 128))
   (column active? db.Boolean :default true)
   [topics
    (db.relationship
      "Topic" :backref "author" :lazy "dynamic" :order-by "Topic.id")]
   [posts
    (db.relationship
      "Post" :backref "author" :lazy "dynamic"
      :cascade "all,delete" :order-by "Post.id")]
   [--repr-- (fn [self] (% "<User %r>" self.email))]
   [password (with-decorator property
               (fn [self]
                 (raise (AttributeError "password is not readable"))))]
   [password (with-decorator password.setter
               (fn [self password]
                 (setv self.password-hash
                   (generate-password-hash password))))]
   [check-password (fn [self password]
                     (check-password-hash self.password-hash password))]
   [url (with-decorator property
          (fn [self] (url-for 'user.profile :id self.id)))]])

(defn init-app [app]
  (db.init-app app))
