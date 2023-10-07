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
        "https://github.com/jupyter/notebook", "https://github.com/flutter/flutter", "https://github.com/opencv/opencv",
        "https://github.com/facebook/react-native", "https://github.com/openai/DALL-E", "https://github.com/WongKinYiu/yolov7",
        "https://github.com/jenkinsci/jenkins", "https://github.com/ansible/ansible", "https://github.com/microsoft/LightGBM",
        "https://github.com/elastic/elasticsearch", "https://github.com/OpenBMB/ChatDev", "https://github.com/Pythagora-io/gpt-pilot",
        "https://github.com/ToolJet/ToolJet", "https://github.com/arc53/DocsGPT", "https://github.com/ArduPilot/ardupilot",
        "https://github.com/rust-lang/rust", "https://github.com/Homebrew/brew", "https://github.com/SerenityOS/serenity",
        "https://github.com/JabRef/jabref", "https://github.com/commons-app/apps-android-commons", "https://github.com/xwiki/xwiki-platform",
        "https://github.com/authorjapps/zerocode", "https://github.com/sirixdb/sirix", "https://github.com/knaxus/problem-solving-javascript",
        "https://github.com/larymak/Python-project-Scripts"
        ]

#Empty arrays to store data
titles, users, projects, indexs, abouts, license, stars, languages = [], [], [], [], [], [], [], []

for url in urls:
    r = requests.get(url)
    soup = BeautifulSoup(r.text, 'html.parser')

    # Stores the title of the open source project so if a project is https://github.com/user/project it will store /user/project/.
    # This will be useful to get the stars, forks, watching, and more data from the project
    title_element = soup.find('title')
    title_text = title_element.get_text().strip().replace('GitHub - ', '/').split(':')
    extracted_title = title_text[0].strip() + "/"
    titleArray = extracted_title.split('/')
    user = titleArray[1]
    project = titleArray[2]

    
    # Find the element that contains the "About" description Extract the text from the "About" element
    borderGridRowElement = soup.find('div', class_='BorderGrid-row')
    about_text = borderGridRowElement.find('p').get_text().strip()

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
    a_tag = borderGridRowElement.find("a", href=re.compile(star_href))
    span_tag = a_tag.find('strong')
    star_text = span_tag.get_text().strip()

   #Find the languages used in the project
    languages_div = soup.find('h2', string='Languages').find_next('div')
    language_text = languages_div.findAll('span', {'aria-label': True})
    language_array = []
    for span in language_text:
        aria_label = span['aria-label']
        language_array.append(aria_label)



    titles.append(extracted_title)
    users.append(user)
    projects.append(project)
    indexs.append(url)
    abouts.append(about_text)
    license.append(license_text)
    stars.append(star_text)
    languages.append(language_array)


data = {
    "User" : users,
    "Project" : projects,
    "Repository URL": indexs,
    "About": abouts,
    "License": license,
    "Stars": stars,
    "Languages": languages,
    }

df = pd.DataFrame(data)
csv_file_path = 'githubscraper.csv'
df.to_csv(csv_file_path, index=False)
print(df.to_csv())
