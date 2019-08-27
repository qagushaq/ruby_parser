# ruby test.rb https://www.petsonic.com/snacks-huesos-para-perros/ test
# ruby test.rb https://www.petsonic.com/vetnova/ test2
# ruby test.rb https://www.petsonic.com/pienso-natura-diet/ test3

require 'nokogiri'
require 'csv'
require 'curb'
	
def get_page(url)#парсинг страниц
	Nokogiri::HTML(Curl.get(url).body_str) 
end
	
def get_count_products(url)#подсчет продуктов в категории
	url.xpath("//img[@itemprop='image']").size 
end
	
def writer_to_file(file,product_info)#запись в файл инфы о каждом продукте
	CSV.open(file+".csv", "a")  do |csv|		
	csv <<  product_info
	end
end
	
def category_parse_and_writer(page,file)#парсинг категории и запись в файл
	category_parser(page,file)		
end

def category_parser(page,output_file)#парсинг категории
	page.xpath('.//a[@class="product-name"]/@href').each do |product_url|		
		#информация о  каждом товаре в категории с записью в файл
		product_page = get_page(product_url)
		parse_each_product(product_page,output_file)	
	end		
end
		
def parse_each_product(page,output_file)#парсинг каждого продукта
	name = page.xpath('//*[@id="center_column"]/div/div/div[1]/div[1]/p/text()') 
	image = page.xpath('//*[@id="bigpic"]/@src')
	page.xpath('//*[@class = "attribute_radio_list"]/*' ).each do |i| 
		ves = i.xpath('.//span[@class = "radio_label"]').text.strip
		price = i.xpath('.//span[@class = "price_comb"]').text.strip
		product_info = ["#{name} - #{ves} ; #{price}; #{image}"]
		writer_to_file(output_file,product_info)
	end
end

url_category = ARGV[0]
output_file = ARGV[1]

if (url_category.nil? || url_category.empty?) #проверка переданных аргументов
	puts "Запустите скрипт в такой форате ruby 123.rb URL_CATEGORY NAME_OUTPUT_FILE\n"
	else
		if(output_file.nil? || output_file.empty?)
		puts "Запустите скрипт в такой формате ruby 123.rb URL_CATEGORY NAME_OUTPUT_FILE\n"
			else 
			puts "Переменные переданы\n"
			puts "Началась работа программы..\n"
			CSV.open(output_file+".csv", "wb", write_headers: true, headers: ["Name;Price;Image"])
			page_index = 1
			#это нужно т.к. 1 страница категории имеет такой вид /snacks-huesos-para-perros/  без ?p=1
			category_page = get_page(url_category)
			print "Собираем информацию о каждом товаре в категории...\n"
			while true do
				#на каждой странице до 25 товаров
				items_count = get_count_products(category_page)
				puts "#{items_count} товаров собрано со страницы:  #{url_category+'?p='+ page_index.to_s}"
				puts "Происходит запись в файл #{output_file}.csv, немного подождите..\n"
				category_parse_and_writer(category_page,output_file)
			break if items_count < 25  #если меньше 25, то это последняя страница
			page_index += 1
			category_page = Nokogiri::HTML(Curl.get(url_category+'?p='+ page_index.to_s).body_str)
		end
		puts "Работа программы завершена, результат сохранен в  #{output_file}.csv !\n"
	end
end





















=begin

page_index = 1
  category_page = Nokogiri::HTML(Curl.get(url_category).body_str) 
  print "Собираем информацию о каждом товаре в категории...\n"

products = []
	
while true do
		#на каждой странице до 25 товаров
		puts items_count = category_page.xpath("//img[@itemprop='image']").size 
			
								category_page.xpath('.//a[@class="product-name"]/@href').each do |product_url|
					
					
								product_page = Nokogiri::HTML(Curl.get(product_url).body_str)
								product_name = product_page.xpath('//*[@id="center_column"]/div/div/div[1]/div[1]/p/text()') 

								products <<  ["#{product_name}"]
								end
				
				
	#если меньше 25, то это последняя страница
	break if items_count < 25  
	 page_index += 1
	category_page = Nokogiri::HTML(Curl.get(url_category+'?p='+ page_index.to_s).body_str)
	
end

CSV.open(output_file+".csv", "wb") do |csv|
csv << ['Name']
csv << products

end


=end

=begin

class Product
	attr_accessor :name, :ves, :price, :image_url
	def initialize(product_name, product_ves, product_price, product_image)
		@name = product_name
		@ves = product_ves
		@price	= product_price
		@image_url = product_image
	end
end

=end

=begin
#СОБИРАЕТ ВСЕ ССЫЛКИ НА ТОВАРЫ СНАЧАЛА В ОДНОМ КАТЕГОРИ ПЕЙДЖ, ПОТОМ ЕГО ПЕРЕЗАПИСЫВАЕТ ДРУГИМИ, НАДО В ПЕРЕМЕННУЮ СНАЧАЛ
#С ПЕРВОГО КАТЕГОРИ ПЕЙДЖ ПОТОМ СО ВТОРОГО ЗАПИСАТЬ
url_category = ARGV.first
page_index=1
# проход по  url_category + '?p=' + page_index.to_s
 category_page = Nokogiri::HTML(Curl.get(url_category).body_str)
	while true do
	product_count = category_page.xpath("//img[@itemprop='image']").size
	break if product_count < 25	
	page_index += 1
		category_page = Nokogiri::HTML(Curl.get(url_category+'?p='+page_index.to_s).body_str)
end
=end