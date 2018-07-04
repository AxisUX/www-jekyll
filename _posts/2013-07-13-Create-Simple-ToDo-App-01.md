---
layout: post
title: "Simple ToDo App 01"
author: David Midlo
tags: [ html, experiment ]
categories: [ fieldnotes, Engineering, Development]
---

<div id="ToDoApp01Container">
    <ul id="ToDoApp01List" contenteditable>
        <li>Click Here to Edit a List Item</li>
        <li>Hit 'Enter' to Create a New List Item</li>
        <li>Click 'Save All' to commit the current List to Storage</li>
        <li>Click 'Clear All' to clear the current List and restore this default list</li>
    </ul>
    <p>
        <a href="#" id="ToDoApp01SaveAll">Save All</a>
        <a href="#" id="ToDoApp01ClearAll">Clear All</a>
    </p>
</div>

<script
  src="https://code.jquery.com/jquery-3.3.1.slim.min.js"
  integrity="sha256-3edrmyuQ0w65f8gfBsqowzjJe2iM6n0nKciPUp8y+7E="
  crossorigin="anonymous"></script>
<script type="text/javascript">
    $(document).ready(function() {
        var ToDoApp01List = document.getElementById('ToDoApp01List');

        $('#ToDoApp01SaveAll').click(function(error){
            error.preventDefault();

            localStorage.setItem('ToDoApp01', ToDoApp01List.innerHTML)
        });

        $('#ToDoApp01ClearAll').click(function(error){
            error.preventDefault();

            localStorage.clear();

            location.reload();
        });

        loadToDo01();

        function loadToDo01(){
            if(localStorage.getItem('ToDoApp01')) {
                ToDoApp01List.innerHTML = localStorage.getItem('ToDoApp01')
            }
        }

    });
</script>