---
layout: post
title: Syntax Highlighting for Liquid Snippet
author: David Midlo
tags: [ jekyll, post, liquid, syntax highlighting, code block ]
categories: [ field notes, Engineering, Development]
---
# Problem:
Liquid Engine attempts to parse code snippet contained within a markdown code block.

# Reported Errors:
rendered code snippet is missing any code with enclosing liquid syntax braces

Example Input Code:
{% highlight html %}
{% raw %}
{% highlight html %}
    {%- if page.author -%}
        • <span itemprop="author" itemscope itemtype="http://schema.org/Person"><span class="p-author h-card" itemprop="name">{{ page.author }}</span></span>
    {%- endif -%}</p>
{% endhighlight %}
{% endraw %}
{% endhighlight %}

Example Output
{% highlight html %}
    {%- if page.author -%}
        • <span itemprop="author" itemscope itemtype="http://schema.org/Person"><span class="p-author h-card" itemprop="name">{{ page.author }}</span></span>
    {%- endif -%}</p>
{% endhighlight %}

- The `<span>` example above is actually enclosed with an `{% raw %}{%- if -%}{%- endif -%}{% endraw %}` statement but is not showing up.
- The above example also unwantedly renders the post author `David Midlo` when in actuallity `{% raw %}{{ page.author }}{% endraw %}` was the desired text for the code snippet.

# Solution:
Use of the `{% raw %}{% raw %}{% endraw %}` declaration solves this problem by directing liquid to parse the enclosed text as raw text instead of a liquid declaration

Solution Code:
{% highlight html %}
{{ "{%" }} highlight html %}
{{ "{%" }} raw %}
   {{ "{%-" }} if page.author -%}
        • <span itemprop="author" itemscope itemtype="http://schema.org/Person"><span class="p-author h-card" itemprop="name">{% raw %}{{ page.author }}{% endraw %}</span></span>
    {{ "{%-" }} endif -%}</p>
{{ "{%" }} endraw %}
{{ "{%" }} endhighlight %}    
{% endhighlight %}



# Attempted Solutions:
- For a line-by-line solution, escape the beginning `{% raw %}{%-{% endraw %}` tag by wrapping a `{% raw %}{{ "<content>" }}{% endraw %}` block around it. *The closing tag does not need to be escaped as it is ignored by the liquid parser.*
    + So `{% raw %}{%- if page.author -%}{% endraw %}` becomes `{% raw %}{{ "{%-" }} if page.author -%}{% endraw %}`
    + and `{% raw %}{%- endif -%}{% endraw %}` becomes `{% raw %}{{ "{%-" }} endif -%}{% endraw %}`

# Additonal Notes:
- The line-by-line technique was used to present the solution code above. This was used here because liquid has trouble with nested `{% raw %}{% raw %}{% endraw %}` tags.


# References:
- [Is there “no-parse” block for Liquid?](https://stackoverflow.com/questions/19996881/is-there-no-parse-block-for-liquid)

# Possible Enhancements:
- It would also be reasonable to use an embed like github gists or something similar.
