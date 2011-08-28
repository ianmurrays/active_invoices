Active Invoices is a very simple Ruby on Rails invoicing application, built using the amazing [active_admin][1] gem.

## Installation & Usage

Clone the repository:

    git clone https://github.com/ianmurrays/active_invoices
  
And run the following commands:

    bundle install
    rake db:schema:load # or you can run rake db:migrate

You're going to need to create a user on the database using `irb`:

    rails console
    >> AdminUser.create! :email => "admin@admin.org", :password => "admin", :password_confirmation => "admin"

Now, run `rails server` and point your server to [http://localhost:3000](http://localhost:3000) and try out your new installation.

[1]: https://github.com/gregbell/active_admin