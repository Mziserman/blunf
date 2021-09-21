#! /usr/bin/env ruby

columns = %w[
  index
  due_on
  remaining_capital_start
  remaining_capital_end
  period_theoric_interests
  delta
  accrued_delta
  amount_to_add
  period_interests
  period_capital
  total_paid_capital_end_of_period
  total_paid_interests_end_of_period
  period_total
  capitalized_interests_start
  capitalized_interests_end
  period_rate
  period_calculated_capital
  period_calculated_interests
  period_reimbursed_capitalized_interests
  period_leap_days
  period_non_leap_days
  period_fees
  period_calculated_fees
  capitalized_fees_start
  capitalized_fees_end
  period_reimbursed_capitalized_fees
  period_fees_rate
  period_reimbursed_guaranteed_interests
  period_reimbursed_guaranteed_fees
]

# C * (1 + (F + I)/12)^ID - C*(1 + I/12)^ID

require 'pry'
require 'csv'
not_float = %w[index due_on]
files = Dir.glob('./loans_csv/*/*.csv')
borrower_files = Dir.glob('./loans_csv/*/borrower/*.csv')
lender_files = Dir.glob('./loans_csv/*/lender/*.csv')

(files + borrower_files + lender_files).each do |file|
  next unless file.include?('bullet')

  data = CSV.read(file)
  timetable = data.map do |term|
    hash = [columns, term].transpose.to_h
    hash['index'] = hash['index'].to_i
    hash['due_on'] = Date.strptime(hash['due_on'], '%m/%d/%Y')
    (columns - not_float).each { |float_column| hash[float_column] = hash[float_column].to_f }
    hash
  end

  fees_rate = timetable.first['period_fees_rate']
  interests_rate = timetable.first['period_interests_rate']
  initial_capital = timetable.first['remaining_capital_start']

  bullet_duration = (
    if file.include?('infine')
      file.split('bullet_')[1].split('_infine')[0].to_i
    else
      timetable.last['index']
    end
  )

  capitalized_fees = []

  capitalized_fees = (0..bullet_duration).map do |term|
    fees_part = initial_capital * (1 + interests_rate + fees_rate)**term
    interests_part = initial_capital * (1 + interests_rate)**term
    capitalized_fees << fees_part - interests_part
  end
end
