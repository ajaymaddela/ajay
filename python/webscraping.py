import requests
import pandas
from bs4 import BeautifulSoup

response=requests.get("https://www.flipkart.com/realme-12-pro-5g-navigator-beige-256-gb/p/itm7f042fb6aebdb?pid=MOBGWH8SFQGSBNDU&lid=LSTMOBGWH8SFQGSBNDURMZVFN&marketplace=FLIPKART&store=tyy%2F4io&srno=b_1_1&otracker=browse&fm=neo%2Fmerchandising&iid=e64fc1f0-70a0-4754-bbd9-cd8760c790ba.MOBGWH8SFQGSBNDU.SEARCH&ppt=browse&ppn=browse&ssid=w6nd8xtf0w0000001713246120096")
# print(response)
soup=BeautifulSoup(response.content,'html.parser')
# print(soup)
# images=soup.find_all('img',class_='o-bXKmQE')
# image=[]
# for i in images[0:5]:
#     d=i.text
#     image.append(d)
# print(name)

# names=soup.find_all('a',class_='s1Q9rs')
# name=[]
# for i in names[0:5]:
#     d=i.text
#     name.append(d)
# print(name)


# exchange=soup.find_all('div',class_='_32JtDB')
# label=[]
# for i in exchange[0:5]:
#     d=i.text
#     label.append(d)
# print(label)

images=soup.find_all('div',class_='_2CxnBI')
image=[]
for i in images[0:5]:
    d=i.text
    image.append(d)
print(image)
