module ApplicationHelper
  def footer_page
    @footer_page ||= Alchemy::Page.where(page_layout: "footer").first
  end
end
