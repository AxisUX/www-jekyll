---
layout: post
title: "HTML Element Attributes"
author: David Midlo
tags: [ html, structure, attributes ]
categories: [ fieldnotes, Engineering, Development]
---
# Problem:
html elements by themselves, provide sematic structure for a html document. There is a need however to discribe further details of the specific elements themselves.  How can attributes be asigned to html elements? 

# Solution:
html attributes supply further detail concerning an element. A a 'name and value pair' is used within the opening tag of the html element.

{% highlight html %}
<span lang="en-us" title="Inbound Leads">
    <a href="inbound/index.html">Inbound Leads</a>
</span>
{% endhighlight %}

{% highlight html %}
<span dir="rtl" lang="ar" title="تَنْزيلات">
    <a href="ar/promo/index.html">تَصْفِية نِهايةِ المَوْسِمِ</a>
</span>
{% endhighlight %}