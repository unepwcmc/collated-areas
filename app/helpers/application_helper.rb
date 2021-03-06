module ApplicationHelper
  def page_title 
    'Global Database on Protected Area Management Effectiveness'
  end

  def page_description
    'The Global Database on Protected Area Management Effectiveness (GD-PAME) is the most comprehensive global database of protected area management effectiveness (PAME) evaluations. It indicates if a protected area in the World Database on Protected Areas (WDPA) has been assessed. it is compiled in collaboration with a wide range of governmental and non-governmental organizations and updated on a monthly basis'
  end

  def url_encode (text)
    ERB::Util.url_encode(text)
  end

  def encoded_page_url
    url_encode(request.original_url)
  end

  def social_image
    image_url('social.jpg')
  end

  def social_image_alt
    'Forest'
  end

  def create_social_facebook_link
    title = url_encode('Share ' + page_title + ' on Facebook')
    url = encoded_page_url
    href = 'https://facebook.com/sharer/sharer.php?u=' + url

    link_to '', href, title: title, class: 'social--share social--facebook', target: '_blank'
  end

  def create_social_linkedin_link
    title = url_encode('Share ' + page_title + ' on LinkedIn')
    url = encoded_page_url
    href = 'https://www.linkedin.com/shareArticle?url=' + url

    link_to '', href, title: title, class: 'social--share social--linkedin', target: '_blank'
  end

  def create_social_twitter_link
    title = url_encode('Share ' + page_title + ' on Twitter')
    text = url_encode(page_title + ' - The most comprehensive global database of protected area management effectiveness (PAME) evaluations')
    url = encoded_page_url
    href = 'https://twitter.com/intent/tweet/?text=' + text + '&url=' + url
    
    link_to '', href, title: title, class: 'social--share social--twitter', target: '_blank'
  end

  def create_social_email_link
    title = url_encode('Share ' + page_title + ' via Email')
    url = encoded_page_url
    subject = url_encode(page_title)
    body = url_encode(page_title + "\n\nSearch the database of the most comprehensive global database of protected area management effectiveness (PAME) evaluations. It indicates if a protected area in the World Database on Protected Areas (WDPA) has been assessed. it is compiled in collaboration with a wide range of governmental and non-governmental organizations and updated on a monthly basis\n\n") + url
    href = 'mailto:?subject=' + subject + '&body=' + body

    link_to '', href, title: title, class: 'social--share social--email', target: '_self'
  end
end
