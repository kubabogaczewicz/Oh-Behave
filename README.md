Oh Behave
=========

*warning: this is an old collage project, created when RoR 2 was still beta.*

What it is
----------

Plugin supporting writing unobtrusive JavaScript in Ruby on Rails. It works a bit different from UJS4Rails, for in this one there is an explicite assumption, that programmer knows what unobtrusive JavaScript is about and wants to implement it. This tools will not automagically turn your application into a standard-compilant,
accessible site. But it can greatly help you once you've decided to go unobtrusive JavaScript.

Main thing about this plugin is method

  `behaviour`

which allows you to declaratively describe which actions have which behaviours. To read more please check RubyDoc.

Most functions are internal for the plugin and thereso lacking documentation. What user should read is description to method behaviour and describes inside configuration (that is oh_behave.rb).

If something does not work as it should please check if you have `prototype.js` >= 1.6 and `lowpro` > 0.41. Prototype in that version comes with Rails now, lowpro is included with plugin should you have problems with finding it yourself.

*best wishes*