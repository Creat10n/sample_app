module ApplicationHelper
  # Return full title on a per-page basis.
  def full_title page_title = ""
    base_title = I18n.t("dictionary.base_title")
    page_title.empty? ? base_title : (page_title + " | " + base_title)
  end
end
