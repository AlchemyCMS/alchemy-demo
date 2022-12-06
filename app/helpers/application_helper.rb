module ApplicationHelper
  def microsite
    Alchemy::Page.published.where(page_layout: "microsite").first
  end

  def blog_page(page)
    page.children.published.where(page_layout: "blog").first
  end

  def blog_articles(page)
    blog_page = blog_page(page)
    blog_page&.elements&.named(:blog_post)
  end

  def footer_page
    @footer_page ||= Alchemy::Page.where(page_layout: "footer").first
  end
end
