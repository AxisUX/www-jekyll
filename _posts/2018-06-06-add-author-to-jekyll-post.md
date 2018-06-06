---
layout: post
title: Add Author to Jekyll Post
author: David Midlo
tags: [ jekyll, post, front matter ]
categories: [ field notes, Engineering, Development]
---
# Problem:
Author should be listed on post in Jekyll.

# Reported Errors:
Author attribution not listed along with post in default jekyll theme (minima)

# Solution:
- Ensure YAML front-matter of post includes the `author` tag.
{% highlight yml %}
---
layout: post
title: Add Author to Jekyll Post
author: David Midlo
tags: [ jekyll, post, front matter ]
categories: [ field notes, Engineering, Development]
---
{% endhighlight %}



# Attempted Solutions:
- To no effect, On first attempt I used an upper-case `Author:` within the front-matter to declare the author attribute.  Front-matter requires lower-case 'author:'

# Additonal Notes:
- The conditional for whethor or not to include the author attribute is is found in the `post.html` layout in `.\_layouts\`.

{% highlight html %}
{% raw %}
    {%- if page.author -%}
        • <span itemprop="author" itemscope itemtype="http://schema.org/Person"><span class="p-author h-card" itemprop="name">{{ page.author }}</span></span>
    {%- endif -%}</p>
{% endraw %}
{% endhighlight %}


# References:
- [Front Matter Defaults](https://jekyllrb.com/docs/configuration/#front-matter-defaults)

# Possible Enhancements:
- [Add Author Bio to Site](https://dev.to/m0nica/how-to-add-author-bio-to-posts-in-jekyll-3g1)
- [Setup Post Template to Support Multiple Authors](https://stackoverflow.com/questions/15189008/how-can-i-have-multiple-authors-for-one-post-in-jekyll)
- [Set Default Author for Whole Jekyll Blog](https://jekyllrb.com/docs/configuration/#front-matter-defaults)
