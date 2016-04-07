
ary = []
File.open("test").read.each_line do |line|
    ary.push eval(line)
end

primes = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67, 71, 73, 79, 83, 89, 97, 101, 103, 107, 109, 113, 127, 131, 137, 139, 149, 151, 157, 163, 167, 173, 179, 181, 191, 193, 197, 199, 211, 223, 227, 229, 233, 239, 241, 251, 257, 263, 269, 271, 277, 281, 283, 293, 307, 311, 313, 317, 331, 337, 347, 349, 353, 359, 367, 373,    379, 383, 389, 397, 401, 409, 419, 421, 431,433]

ans = []
0.upto 82 do |i|

    count = 0
    p = primes[i]
    a = ary[i+1][1].to_i
    p "#{i} #{a}"
while a % p == 0
    count = count +1
    a = a/p
end
ans.push count
end

#p ary[1][1]
ans.each do |a|
    print a.chr
end
exit
ans = []
primes.each do |p|
    count = 0
while a % p == 0
    count = count +1
    a = a/p
end
ans.push count
end
ans.each do |a|
    print a.chr
end
#puts 


