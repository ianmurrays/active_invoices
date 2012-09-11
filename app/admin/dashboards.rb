ActiveAdmin::Dashboards.build do
  
  section "Statistics" do
    div :class => "attributes_table" do
      table do
        tr do
          th "Invoices This Month"
          td number_with_delimiter(current_admin_user.invoices.this_month.count)
        end
    
        tr do
          th "Invoices Paid This Month"
          td number_with_delimiter(current_admin_user.invoices.this_month.where(:status => Invoice::STATUS_PAID).count)
        end
    
        tr do
          th "Income This Month"
          td number_to_currency(current_admin_user.invoices.this_month.where(:status => Invoice::STATUS_PAID).all.sum(&:total)), :style => "font-weight: bold;"
        end
      end
    end
  end
  
  section "Latest Invoices" do
    table_for current_admin_user.invoices.order('created_at desc').limit(5).all do |t|
      t.column("Status") { |invoice| status_tag invoice.status, invoice.status_tag }
      t.column("Code") { |invoice| link_to "##{invoice.code}", admin_invoice_path(invoice) }
      t.column("Client") { |invoice| link_to invoice.client.name, admin_client_path(invoice.client) }
      t.column("Total") { |invoice| number_to_currency invoice.total }
    end
  end

  # Define your dashboard sections here. Each block will be
  # rendered on the dashboard in the context of the view. So just
  # return the content which you would like to display.
  
  # == Simple Dashboard Section
  # Here is an example of a simple dashboard section
  #
  #   section "Recent Posts" do
  #     ul do
  #       Post.recent(5).collect do |post|
  #         li link_to(post.title, admin_post_path(post))
  #       end
  #     end
  #   end
  
  # == Render Partial Section
  # The block is rendered within the context of the view, so you can
  # easily render a partial rather than build content in ruby.
  #
  #   section "Recent Posts" do
  #     div do
  #       render 'recent_posts' # => this will render /app/views/admin/dashboard/_recent_posts.html.erb
  #     end
  #   end
  
  # == Section Ordering
  # The dashboard sections are ordered by a given priority from top left to
  # bottom right. The default priority is 10. By giving a section numerically lower
  # priority it will be sorted higher. For example:
  #
  #   section "Recent Posts", :priority => 10
  #   section "Recent User", :priority => 1
  #
  # Will render the "Recent Users" then the "Recent Posts" sections on the dashboard.

end
