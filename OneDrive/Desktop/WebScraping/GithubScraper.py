try:
    import requests
    import re
    from bs4 import BeautifulSoup
    import pandas as pd
except Exception as e:
    print("Some Modules are Missing {}".format(e))

# URLS of Github Repository Open Source Project that we want to scrape infromation from
urls = ["https://github.com/torvalds/linux", "https://github.com/tensorflow/tensorflow", "https://github.com/microsoft/vscode",
        "https://github.com/kubernetes/kubernetes", "https://github.com/pytorch/pytorch", "https://github.com/tiangolo/fastapi",
        "https://github.com/jupyter/notebook", "https://github.com/flutter/flutter", "https://github.com/opencv/opencv"   ]

#Empty arrays to store data
titles, indexs, abouts, license, stars = [], [], [], [], []

for url in urls:
    r = requests.get(url)
    soup = BeautifulSoup(r.text, 'html.parser')

    # Stores the title of the open source project so if a project is https://github.com/user/project it will store /user/project/.
    # This will be useful to get the stars, forks, watching, and more data from the project
    title_element = soup.find('title')
    title_text = title_element.get_text().strip().replace('GitHub - ', '/').split(':')
    extracted_title = title_text[0].strip() + "/"
    
    # Find the element that contains the "About" description Extract the text from the "About" element
    about_element = soup.find('div', class_='BorderGrid-row')
    about_text = about_element.find('p').get_text().strip()

    # Find the License information of each project for looking at the project data containing license.txt or license
    license_element = soup.find('a', href=re.compile(r'/LICENSE(\.txt)?$', re.IGNORECASE))
    if license_element:
        license_text = license_element.get_text(strip=True)
    else:
        license_element = soup.find('a', string=re.compile(r'license', re.IGNORECASE))
        if license_element:
            license_text = license_element.get_text(strip=True)
        else:
            license_text = "License not specified"


    star_href = re.escape(extracted_title) + r'stargazers$'
    # Find the <a> tag using the pattern where the stars are from the corresponding star href attribute
    a_tag = about_element.find("a", href=re.compile(star_href))
    span_tag = a_tag.find('strong')
    star_text = span_tag.get_text().strip()



    titles.append(extracted_title)
    indexs.append(url)
    abouts.append(about_text)
    license.append(license_text)
    stars.append(star_text)


data = {
    "User/Project": titles,
    "Repository URL": indexs,
    "About": abouts,
    "License": license,
    "Stars": stars
    }

df = pd.DataFrame(data)
print(df.to_csv())