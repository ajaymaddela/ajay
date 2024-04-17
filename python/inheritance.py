# it pillar of oops in python 
# all the properties comes from parent to child
# one parent and one child is called single inheritance
# two parent generations and child is called multilevel inheritance
# father and mother properties to one child called multiple inheritance 
# one parent and two childs is called hierarchy inheritance

#  single level inheritance
# class parent():
#      def output(self):
#         print("iam parent")
# class child(parent):
#      def outputc(self):
#          print('iam child')
# c=child()
# c.outputc()
# c.output()


# multilevel inheritance
# class grandfather():
#     def outputgf(self):
#         print("im grand father")
# class parent(grandfather):
#      def output(self):
#         print("iam parent")
# class child(parent):
#      def outputc(self):
#          print('iam child')
# c=child()
# c.outputgf()
# c.output()
# c.outputc()



# multiple inheritance
# class father():
#     def outputgf(self):
#         print("im  father")
# class mother():
#      def output(self):
#         print("iam mother")
# class child(father,mother):
#      def outputc(self):
#          print('iam child')
# c=child()
# c.outputgf()
# c.output()
# c.outputc()

# hierarchy
# class father():
#     def outputgf(self):
#         print("im father")
# class child1(father):
#      def output(self):
#         print("iam child1")
# class child2(father):
#      def outputc(self):
#          print('iam child2')
# c=child1()
# c2=child2()
# c.outputgf()
# c.output()
# c2.outputc()