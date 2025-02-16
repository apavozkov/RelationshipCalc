require 'minitest/autorun'
require 'open3'
require 'json'
require_relative '../Algorithm/Anton'

class TestAnton < Minitest::Test
  def setup
    @people_data = {
      "people" => [
        { "name" => "Alice", "gender" => "W" },
        { "name" => "Bob", "gender" => "M" },
        { "name" => "Charlie", "gender" => "M" }
      ],
      "marriages" => [
        { "husband" => "Bob", "wife" => "Alice" }
      ],
      "parent_child" => [
        { "parent" => "Alice", "child" => "Charlie" },
        { "parent" => "Bob", "child" => "Charlie" }
      ]
    }.to_json

    @invalid_json = '{ "people": [ { "name": "Alice", "gender": "W" } ]' # Missing closing brace
    @file_path = 'data.json'
    @formulas_path = 'formulas.json'
  end

  def test_load_people_data_valid
    File.write(@file_path, @people_data)
    people = load_people_data(@file_path)
    assert_equal 3, people.size
    assert_equal 'W', people['Alice'][:gender]
    assert_equal 'M', people['Bob'][:gender]
    assert_equal 'M', people['Charlie'][:gender]
    assert_includes people['Bob'][:spouses], 'Alice'
    assert_includes people['Alice'][:spouses], 'Bob'
    assert_includes people['Alice'][:children], 'Charlie'
    assert_includes people['Bob'][:children], 'Charlie'
    assert_includes people['Charlie'][:parents], 'Alice'
    assert_includes people['Charlie'][:parents], 'Bob'
  ensure
    File.delete(@file_path) if File.exist?(@file_path)
  end

  def test_load_people_data_invalid
    File.write(@file_path, @invalid_json)
    people = load_people_data(@file_path)
    assert_nil people
  ensure
    File.delete(@file_path) if File.exist?(@file_path)
  end

  def test_load_people_data_file_not_found
    people = load_people_data('non_existent_file.json')
    assert_nil people
  end

  def test_load_formulas_valid
    valid_formulas = { 'formula1' => 'a + b', 'formula2' => 'a * b' }.to_json
    File.write(@formulas_path, valid_formulas)
    formulas = load_formulas(@formulas_path)
    assert_equal 2, formulas.size
    assert_equal 'a + b', formulas['formula1']
    assert_equal 'a * b', formulas['formula2']
  ensure
    File.delete(@formulas_path) if File.exist?(@formulas_path)
  end

  def test_load_formulas_invalid
    File.write(@formulas_path, @invalid_json)
    formulas = load_formulas(@formulas_path)
    assert_nil formulas
  ensure
    File.delete(@formulas_path) if File.exist?(@formulas_path)
  end

  def test_load_formulas_file_not_found
    formulas = load_formulas('non_existent_formulas.json')
    assert_nil formulas
  end

  def test_parse_step_valid
    step = parse_step('ELDRE(M)')
    assert_equal({ op: 'ELDRE', gender: 'M' }, step)

    step = parse_step('LIK(W)')
    assert_equal({ op: 'LIK', gender: 'W' }, step)

    step = parse_step('UNG(M)')
    assert_equal({ op: 'UNG', gender: 'M' }, step)
  end

  def test_parse_step_invalid
    step = parse_step('INVALID')
    assert_nil step

    step = parse_step('ELDRE(X)')
    assert_nil step

    step = parse_step('ELDRE')
    assert_nil step
  end
  def test_apply_step_eldre
    people_data = {
      'Alice' => { gender: 'W', parents: ['Parent1'], spouses: [], children: [] },
      'Parent1' => { gender: 'M', parents: [], spouses: [], children: ['Alice'] }
    }
    step = { op: 'ELDRE', gender: 'M' }
    result = apply_step('Alice', step, people_data, [])
    assert_equal ['Parent1'], result
  end

  def test_apply_step_lik
    people_data = {
      'Alice' => { gender: 'W', parents: [], spouses: ['Bob'], children: [] },
      'Bob' => { gender: 'M', parents: [], spouses: ['Alice'], children: [] }
    }
    step = { op: 'LIK', gender: 'M' }
    result = apply_step('Alice', step, people_data, [])
    assert_equal ['Bob'], result
  end

  def test_apply_step_ung
    people_data = {
      'Alice' => { gender: 'W', parents: [], spouses: [], children: ['Charlie'] },
      'Charlie' => { gender: 'M', parents: ['Alice'], spouses: [], children: [] }
    }
    step = { op: 'UNG', gender: 'M' }
    result = apply_step('Alice', step, people_data, [])
    assert_equal ['Charlie'], result
  end

  def test_apply_step_excluded_names
    people_data = {
      'Alice' => { gender: 'W', parents: [], spouses: ['Bob'], children: [] },
      'Bob' => { gender: 'M', parents: [], spouses: ['Alice'], children: [] }
    }
    step = { op: 'LIK', gender: 'M' }
    result = apply_step('Alice', step, people_data, ['Bob'])
    assert_equal [], result
  end
  def test_process_sub_formula_single_step
    people_data = {
      'Alice' => { gender: 'W', parents: ['Parent1'], spouses: [], children: [] },
      'Parent1' => { gender: 'M', parents: [], spouses: [], children: ['Alice'] }
    }
    result = process_sub_formula('ELDRE(M)', 'Alice', people_data)
    assert_equal ['Parent1'], result
  end
  
  def test_process_sub_formula_multiple_steps
    people_data = {
      'Alice' => { gender: 'W', parents: ['Parent1'], spouses: [], children: [] },
      'Parent1' => { gender: 'M', parents: ['Grandparent1'], spouses: [], children: ['Alice'] },
      'Grandparent1' => { gender: 'M', parents: [], spouses: [], children: ['Parent1'] }
    }
    result = process_sub_formula('ELDRE(M)/ELDRE(M)', 'Alice', people_data)
    assert_equal ['Grandparent1'], result
  end
  
  def test_process_sub_formula_no_match
    people_data = {
      'Alice' => { gender: 'W', parents: ['Parent1'], spouses: [], children: [] },
      'Parent1' => { gender: 'M', parents: [], spouses: [], children: ['Alice'] }
    }
    result = process_sub_formula('ELDRE(W)', 'Alice', people_data)
    assert_equal [], result
  end
  
  def test_process_sub_formula_excluded_names
    people_data = {
      'Alice' => { gender: 'W', parents: ['Parent1'], spouses: [], children: [] },
      'Parent1' => { gender: 'M', parents: ['Grandparent1'], spouses: [], children: ['Alice'] },
      'Grandparent1' => { gender: 'M', parents: [], spouses: [], children: ['Parent1'] }
    }
    result = process_sub_formula('ELDRE(M)/ELDRE(M)', 'Alice', people_data)
    assert_equal ['Grandparent1'], result
  end
  
  def test_process_sub_formula_empty_steps
    people_data = {
      'Alice' => { gender: 'W', parents: ['Parent1'], spouses: [], children: [] },
      'Parent1' => { gender: 'M', parents: [], spouses: [], children: ['Alice'] }
    }
    result = process_sub_formula('', 'Alice', people_data)
    assert_equal [], result
  end  

  def test_calculate_relatives_single_sub_formula
    File.write(@file_path, @people_data)
    people = load_people_data(@file_path)
    result = calculate_relatives('ELDRE(M)', 'Charlie', people)
    assert_equal ['Bob'], result
  ensure
    File.delete(@file_path) if File.exist?(@file_path)
  end
  
  def test_calculate_relatives_multiple_sub_formulas
    File.write(@file_path, @people_data)
    people = load_people_data(@file_path)
    result = calculate_relatives('ELDRE(M)&&ELDRE(W)', 'Charlie', people)
    assert_equal ['Bob', 'Alice'], result
  ensure
    File.delete(@file_path) if File.exist?(@file_path)
  end
  
  def test_calculate_relatives_no_match
    people_data = JSON.parse(@people_data)
    result = calculate_relatives('ELDRE(W)', 'Charlie', people_data)
    assert_equal [], result
  end
  
  def test_calculate_relatives_invalid_formula
    people_data = JSON.parse(@people_data)
    result = calculate_relatives('INVALID', 'Charlie', people_data)
    assert_equal [], result
  end
  
  def test_calculate_relatives_empty_formula
    people_data = JSON.parse(@people_data)
    result = calculate_relatives('', 'Charlie', people_data)
    assert_equal [], result
  end
  
  def test_valid_formula_valid
    assert_equal true, valid_formula?('ELDRE(M)')
    assert_equal true, valid_formula?('LIK(W)')
    assert_equal true, valid_formula?('UNG(M)')
    assert_equal true, valid_formula?('ELDRE(M)/LIK(W)')
    assert_equal true, valid_formula?('ELDRE(M)/LIK(W)/UNG(M)')
  end
  
  def test_valid_formula_invalid
    assert_equal false, valid_formula?('INVALID')
    assert_equal false, valid_formula?('ELDRE(X)')
    assert_equal false, valid_formula?('ELDRE')
    assert_equal false, valid_formula?('ELDRE(M)/INVALID')
    assert_equal false, valid_formula?('ELDRE(M)/LIK(X)')
  end
  
  def test_valid_formula_empty
    assert_equal false, valid_formula?('')
  end
end