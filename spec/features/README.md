See [rspec-rails and capybara 2.0: what you need to know](http://www.andylindeman.com/2012/11/11/rspec-rails-and-capybara-2.0-what-you-need-to-know.html)

We'll try to follow that convention for now, i.e. use feature specs / capybara to test user-like interactions, and request specs to test basic routing and api / linked data functionality. 

We can probably cover most of the controller functionality we want to test between those two as well, so don't add to the controller tests that already exist without good reason.

