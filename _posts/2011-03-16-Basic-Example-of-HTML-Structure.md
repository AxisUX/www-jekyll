---
layout: post
title: "Basic Example of HTML Structure"
author: David Midlo
tags: [ html, structure, body, p, paragraph, h1, h2, headings ]
categories: [ fieldnotes, Engineering, Development]
last_modified_at: 2011-10-04
---
# Problem:
Though there are many ways to structure an HTML page, what is the simplest expression of common html structure.  What is the 'Hello World of HTML'?

# Solution:
{% highlight html %}
<html>
<!-- The simplest expression of an html document's structure 
    is  made up of elements that are nested as parent, child, 
    & sibling to each other.-->
<!-- The root parent element of an html document is the <html> 
    element. -->
<!-- Though some elements are 'self-closing' elements, most HTML 
    elements require a closing or 'end' tag. The parent <html> 
    element along with its corresponding </html> closing tag are 
    an example of this. -->
    <head>
    <!-- The <head> element contains meta information about the
    html document such as it's title and other details. This information
    is used by the browser and search engines to categorize, place, and
    rank the html document. -->
    <!-- Content in the <head> tag is not visible within the document. -->
        <title>This is the title of the document or article</title>
        <!-- The <title> tag is used by the brower to label the tab in
        in which the html document is open -->
    </head>
    <body>
    <!-- to get to 'hello world'; after adding the <html> tag,
    a '<body></body>' tag is all that is needed to provide space 
    to declare the content of the HTML document. -->
    <h1>This is the visible title of the document or article</h1>
    <!-- <h1> tags are used to describe the main heading.  Sub-
    headings through to <h1>-<h6> are available -->
        <p>
            This is a paragraph element.  Though it's an elementary idea;
            When a paragraph comes after the title of a page/document, it 
            often serves as a summary, introduction, or brief to the rest
            of the forthcoming text.
        </p>
        <h2>This might be a Supporting Section's Title</h2>
            <p>
                This is a paragraph element pertaining to this supporting
                section.
            </p>
        <h2>This would be a second Support Section's Title</h2>
            <p>
                here is another paragraph element; this time supporting
                the second section's content.
            </p>
    </body>  
</html>
{% endhighlight %}