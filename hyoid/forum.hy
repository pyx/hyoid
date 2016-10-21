;;; -*- coding: utf-8 -*-
;;; Copyright (c) 2016, Philip Xu <pyx@xrefactor.com>
;;; License: BSD New, see LICENSE for details.
"hyoid.forum - forum blueprint"

(import
  [flask [abort flash redirect render-template url-for]]
  [flask-login [current-user]]
  [hyoid.forms [NewPostForm NewTopicForm UpdatePostForm]]
  [hyoid.models [Post Topic db]])

(require hyer.dsl)
(import-for-hyer-dsl)

(defblueprint forum []
  (GET/POST index "/" (login-required
    (def topics (Topic.query.order-by (.desc Topic.updated-on)))
    (process-form NewTopicForm ("forum/index.html" :topics topics)
      (def topic (Topic :title form.title.data :author current-user))
      (def post
        (Post :topic topic :author current-user :content form.content.data))
      (.update-html post)
      (db.session.add topic)
      (db.session.add post)
      (db.session.commit)
      (redirect topic.url))))

  (GET/POST topic "/<int:id>/" (login-required
    (def topic (Topic.query.get-or-404 id))
    (process-form NewPostForm ("forum/topic.html" :topic topic)
      (def post
        (Post :topic topic :author current-user :content form.content.data))
      (.update-html post)
      (db.session.add post)
      (db.session.flush)
      (setv topic.updated-on post.created-on)
      (db.session.commit)
      (flash "New post submitted")
      (def anchor (% "post-%d" (len topic.posts)))
      (redirect-to-view '.topic :id id :_anchor anchor))))

  (GET/POST edit-post "/edit/<int:num>/<int:id>/" (login-required
    (def post (Post.query.get-or-404 id))
    (unless (= post.author current-user)
      (abort 401))
    (process-form (UpdatePostForm :obj post) "forum/edit_post.html"
      (setv post.content form.content.data)
      (.update-html post)
      (db.session.add post)
      (db.session.flush)
      (setv post.topic.updated-on post.updated-on)
      (db.session.add post.topic)
      (db.session.commit)
      (flash "Post updated")
      (def anchor (% "post-%d" num))
      (redirect-to-view '.topic :id post.topic-id :_anchor anchor)))))
