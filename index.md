---
title: 首页
feature_image: "/static/logo.jpg"
feature_text: |
  ## 你好 世界
---

# 欢迎来到我的博客

这是我的个人博客，我将分享关于技术、编程和生活的文章。欢迎浏览！

## 最新文章

<ul>
  {% for post in site.posts limit:5 %}
    <li>
      <a href="{{ post.url }}">{{ post.title }}</a>
      <p>{{ post.excerpt }}</p>
    </li>
  {% endfor %}
</ul>
