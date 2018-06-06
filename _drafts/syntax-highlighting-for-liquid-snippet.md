---
layout: post
title: Syntax Highlighting for Liquid Snippet
author: David Midlo
tags: [ jekyll, post, front matter ]
categories: [ field notes, Engineering, Development]
---
# Problem:
Liquid Engine attempts to parse code snippet contained within a markdown code block.

# Reported Errors:
rendered code snippet is missing any code with enclosing liquid syntax braces and likewise liquid declarations are parsed and executed unwantedly.

Example:
{% highlight html %}
    {%- if page.author -%}
        • <span itemprop="author" itemscope itemtype="http://schema.org/Person"><span class="p-author h-card" itemprop="name">{{ page.author }}</span></span>
    {%- endif -%}</p>
{% endhighlight %}

# Solution:
- 



# Attempted Solutions:
- 

# Additonal Notes:
- 


# References:
- 

# Possible Enhancements:
- 
