require "csv"
require 'sunlight/congress'
require 'erb'
require 'date'

Sunlight::Congress.api_key = "e179a6973728c4dd3fb1204283aaccb5"

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5, '0')[0,5]
end

def clean_phone(phone)
  phone.to_s.gsub!(/\D/, "")
  if phone.length == 11 and phone[0].eql?('1')
    phone[1, 10]
  else
    phone
  end
end

def phone_status(clean_phone)
  if clean_phone.length == 10 or (clean_phone.length == 11 and clean_phone[0].eql?('1'))
    phone_status = "good number"
  else
    phone_status = "bad number"
  end
end

def format_time(time)
  if time > 12
    time = (time - 12).to_s + " p.m."
  else
    time = time.to_s + " a.m."
  end
end

def legislators_by_zipcode(zipcode)
  Sunlight::Congress::Legislator.by_zipcode(zipcode)
end

def save_thank_you_letters(id, form_letter)
  Dir.mkdir("output") unless Dir.exists? "output"

  filename = "output/thanks_#{id}.html"

  File.open(filename, 'w') do |file|
    file.puts form_letter
  end
end

puts "EventManager Initialized!"

contents = CSV.open "event_attendees.csv", headers: true, header_converters: :symbol

template_letter = File.read "form_letter.erb"
erb_template = ERB.new template_letter
popular_times = Hash.new(0)
popular_days = Hash.new(0)

contents.each do |row|
  id = row[0]
  name = row[:first_name]
  home_phone = row[:homephone]
  registration_hour = DateTime.strptime(row[:regdate],'%m/%d/%y %k:%M').hour
  registration_day = DateTime.strptime(row[:regdate],'%m/%d/%y %k:%M').strftime('%A')

  popular_times[registration_hour] += 1
  popular_days[registration_day] += 1

#  cleaned_phone = clean_phone(home_phone)

#  phone_status = phone_status(cleaned_phone)

#  zipcode = clean_zipcode(row[:zipcode])

#  legislators = legislators_by_zipcode(zipcode)

#  form_letter = erb_template.result(binding)

#  save_thank_you_letters(id, form_letter)
end

popular_times.sort_by{|time, number| time}.each do |time, number|
  puts "The numer of people at #{format_time(time)} is #{number}."
end

popular_days.sort_by{|day, number| day}.each do |day, number|
  puts "The numer of people on #{day} is #{number}."
end

