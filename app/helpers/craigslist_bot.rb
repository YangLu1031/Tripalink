class CraigslistBot
  def initialize(car)
    @car = car
    @agent = Mechanize.new
    @agent.user_agent_alias = 'Mac Safari'
  end

  def save_to_file(filename, content)
    File.open(filename, "w") { |file| file.write(content) }
  end

  def get_posting_page
    page = @agent.get('https://post.craigslist.org/c/lax')

    f = page.form_with(:class => "catpick picker")
    f.radiobuttons_with(:name => "id")[5].check

    page2 = @agent.submit(f)

    f = page2.form_with(:class => "catpick picker")
    f.radiobuttons_with(:name => "id", :value => "145")[0].check

    page3 = @agent.submit(f)  # choose the location that fits best:

    f = page3.form_with(:class => "subareapick picker")
    f.radiobuttons_with(:name => "n", :value => "3")[0].check

    page4 = @agent.submit(f)
  end

  def fillin_post form
    form.FromEMail = "annawwayne@hotmail.com"
    form.ConfirmEMail = "annawwayne@hotmail.com"
    form.checkbox_with(:name => "contact_phone_ok").check
    form.checkbox_with(:name => "contact_text_ok").check
    form.contact_phone = "3237179139"
    form.contact_name = "Donghao Li"

    form.PostingTitle = "#{@car.car_model.year} #{@car.car_model.make} #{@car.car_model.model}"  # "2013 MINI Cooper"
    form.Ask = @car.price.to_s  # "16000"
    form.GeographicArea = @car.city  # "Alhambra"
    form.postal = @car.zipcode  # "91801"

    # form.PostingBody = "Heated Seats, Leather, USB. Checkout details about this car at www.tripalink.com"
    form.PostingBody = @car.features.map{ |f| f.name }.join(", ") + ". Checkout details about this car at http://tripalink.com/cars/43"

    form.field_with(:name => "auto_year").options.each{ |o| o.select if o.value == @car.car_model.year.to_s }  # required
    form.auto_make_model = "#{@car.car_model.make} #{@car.car_model.model}"  # "MINI Cooper"  # required
    form.auto_vin = @car.vin  # "WMWSU3C57DT678073"
    form.auto_miles = @car.mileage.to_s  # "13000"

    form.field_with(:name => "auto_fuel_type").options.each{ |o| o.select if o.text == "gas" }  # required

    form.field_with(:name => "auto_title_status").options.each{ |o| o.select if o.text == "clean" }  # required

    form.field_with(:name => "auto_transmission").options.each{ |o| o.select if o.text == "automatic" }  # required

    form
  end

  def main
    page4 = get_posting_page
    save_to_file("cl postingpage.html", page4.body)
    f = page4.form_with(:id => "postingForm")

    fillin_post f

    page5 = @agent.submit(f)  # unpublished draft, no images

    # File.open('cl unpublished draft.html', 'w') { |f| f.write(page5.body) }

    page6 = @agent.submit(page5.forms.last)  # edit images page

    # f = page6.form_with(:class => "add")
    # f.file_uploads.first.file_name = "/Users/xiangli/Downloads/cars/MINI/02.jpg"

    # page7 = @agent.submit(f)
    page7 = page6

    File.open('cl editimages.html', 'w') { |f| f.write(page7.body) }

    images = @car.car_pictures.sort { |a, b| a.picture.url <=> b.picture.url }
    images.each_with_index do |image, index|
      f = page7.form_with(:class => "add")
      url = image.picture.url
      filename = File.basename(image.picture.url)
      # File.open(filename, "w") do |fo| fo.write open(url).read end
      file = Tempfile.new(['cl_', '.jpg'], Rails.root.join('temp'), 'wb')
      file.binmode
      file.write open(url).read
      file.close
      f.file_uploads.first.file_name = file.path  # File.join(Dir.pwd, filename)
      page7 = @agent.submit(f)
      file.unlink
      save_to_file("cl upload%02d.html" % index, page7.body)
    end

    page8 = @agent.submit(page7.forms.last)  # click done with images

    save_to_file('cl donewithimage.html', page8.body)


    # page9 = @agent.submit(page8.forms.first)  # click publish
    # File.open('cl upload submit.html', 'w') { |f| f.write(page9.body) }


  end
end
