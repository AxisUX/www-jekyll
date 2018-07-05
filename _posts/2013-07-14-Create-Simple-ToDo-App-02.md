---
layout: post
title: "Simple ToDo App 02"
author: David Midlo
tags: [ html, experiment ]
categories: [ fieldnotes, Engineering, Development]
---

<div id="ToDoApp02Container">
    <form name="ToDoApp02Form1" method="post" action="">
        <input type="text" name="ToDoApp02ToDoItem" id="ToDoApp02ToDoItem" autofocus>
        <input type="button" name="ToDoApp02AddToDo" id="ToDoApp02AddToDo" value="Add List Item">
    </form>
    <ul id="ToDoApp02ToDoList" class="sortable list">
        <!-- li is populated by JS -->
    </ul>
    <p id="ToDoApp02DoClearAll"><a href="#" id="ToDoApp02ClearAll">Clear All</a></p>
</div>

<script
  src="https://code.jquery.com/jquery-3.3.1.slim.min.js"
  integrity="sha256-3edrmyuQ0w65f8gfBsqowzjJe2iM6n0nKciPUp8y+7E="
  crossorigin="anonymous"></script>

