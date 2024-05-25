# a=2.5
# for i in a,b,c:
#     print(i)
# print(int(a))

# a=2
# print(float(a))


# if condition
# age=19

# if age>18:
#     print("you can still vote")
# elif age==18:
#     print("you can vote")
# else:
#     print("wait for age")

#nested if 

# if True:         #boolean values starting letter should be capital
#     print("hi")
#     if False:
#         print("bye")
#     else:
#         print("gudbye")
# else:
#     print("get lost")


# for i in range(0,10,2):
#   print(i)



# for loop 
#  b="pythonlife"
# for k in b:
#     print(k,end='')  #end helps in printing the values in horizontal 

# while loop
# a=8
# while a<15:
#     a+=1
#     print("hi",a)

#   nested for 
# for i in range(0,10):
#     for j in range(0,10):
#         print(i+j)


# nested while

# i = 1
# while i < 10:
#     j = i
#     while j < 10:
#         print(f"{j} ", end="")
#         j = j + 1
#     print("")
#     i = i + 1
# print("Complete!"


# jumping statements

# a=10
# if a+1:
#     pass   #pass statement helps to skip the if statement is false or  not described properly 
#     print(a)

# break statement
# a="ajaykumar"
# for i in a:
#    if i=='u':
#       break      #for break statement print should be written below to if condition
#    print(i,end='')



# a="ajaykumar"
# for i in a:
#    if i=='k':
#       continue     #for continue statement print should be written below to if condition
#    print(i,end='')



# ajaykumar= "qualitythought"
# print(ajaykumar.upper())

# ajaykumar= "qualitythought"  #helps in length means how many digits along with spaces
# print(len(ajaykumar))

# ajaykumar= "qualitythought"   #to check the number of digits that are present using count
# print(ajaykumar.count("t"))


# ajaykumar= "qualitythought"
# # print(ajaykumar.removeprefix("quality"))
# print(ajaykumar.removesuffix("thought"))


# ajaykumar= " quality thought "
# print(ajaykumar.split()) #to list the above values we use split

# ajaykumar= " quality thought "
# print(ajaykumar.lstrip())
# print(ajaykumar)
# print(ajaykumar.rstrip())



# indexing and slicing 
# a=[1,2,2,2,3,3,3,"ajay"]
# # print(a[-1])
# print(a[0:6:2])

# a=[1,2,2,2,2,2,"ajay"]
# # a.append("kumar")
# a.extend(["kumar","maddela"])
# print(a)

# a=[1,2,2,2,2,2,"ajay"]
# # # a.remove("ajay")
# # a.pop(-1)
# print(a.count(2))
# print(a)



# a=[1,2,2,2,2,2,"ajay"]
# # a.insert(1,"ajay")
# print[]
# # print(a)

# tuple only uses builtin like max min len
# a=(1,2,2)
# print(len(a))

# t1=(1,2,3)
# t2=(2,2,1)
# t=t1+t2
# print(t)
# # print(t1*5)
# for i in t1:
#     for j in t2:
#         print(i*j)

# c=(1,2,2,3,3,"ajay")
# # print(c[-2]) 
# print(c[0:4:2])

# c=(1,2,3,4,5)
# print(min(c))
# print(max(c))
# print(sum(c))
# print(len(c))

# ####dictionary #key:value pair
# a={'a':13,'b':345}
# print(a.get('a'))
# print(a.keys())
# print(a.values())
# print(a.items())
# a.update({11:22})
# print(a)

# for i,j in {1:22,2:11,22:11}.items():
#     print(i,j)

#set doesnot allow duplicates and no indexing 


# a={1,9,2,8,7,6,0}
# '''
# add
# update
# pop
# remove
# '''
# a.add(122)
# a.update({12,112})
# a.pop()
# a.remove(1)
# print(a)

#set methods
#union means all letters
# set1={1,2,3}
# set2={4,5,6}
# print(set1.union(set2))

#intersection print common letters
# set1={1,2,3,4}
# set2={3,4,5,6}
# print(set1.intersection(set2))

#difference prints the set1 letters and deletes the same letters
# set1={1,2,3,4}
# set2={4,5,6,7}
# print(set1.difference(set2))

# superset and subset when the values are same in set1 and 2 it becomes true
# set1={1,2,3,4}
# set2={4,5,6}
# print(set1.issuperset(set2))
# print(set1.issubset(set2))


# functionns def is a keyword and after that is a function definition print is called through fucnction call
# def add(a,b):
#    return a+b,
# def sub(a,b):
#   return a-b
# print({add(2,4),sub(2,4)})

# def func(*a): * for multiple values and ** for a=1,b=2
#     print(a)
# func(1,2,3)

#import functions
# def add(a,b):
#     print(a+b)
# def sub(a,b):
#     print(a-b)
  # calling from import.py

# file handling
# read or write or delete or create and close or open

#file handling in read mode
# s=open('./backend/provider.tf',mode='r')
# print(s.read())
# s.close()

# write it will truncate total change
# s=open('./backend/main.tf',mode='w')
# s.write("ajaykumarmaddelakondapur")
# s.close()

# read and write  after reading write will add at last
# s=open('./backend/main.tf',mode='r+')
# print(s.read())
# s.write("write resources here must required")
# s.close()

#append thats at last word 
# s=open('./backend/main.tf',mode='+a')
# s.write("shutup")
# s.close()

#write and read  write will truncate
# s=open("./backend/main.tf",mode="w+")
# s.write("hi ajay")
# s.seek(0)
# print(s.read())
# s.close()

