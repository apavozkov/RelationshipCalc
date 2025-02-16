filename = 'input.txt'
File.foreach(filename) do |line|
   puts "{name: '" <<  line.split(' ')[0] << "' ,gender: '"  <<line.split(' ')[1][1] << "'}," if line.include?('(')
   puts "{relative: '" <<  line.split(' <->')[0] << "', dependant: '" <<  line.split('<-> ')[1].split(' ')[0] << "', relation: 'married'},"  if line.include?('<->')
   puts "{relative: '" <<  line.split(' ->')[0] << "', dependant: '" <<  line.split('-> ')[1].split(' ')[0] << "', relation: 'child'},"  if line.include?(' ->')
end
