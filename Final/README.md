# Final Data Product Documentation 

### **Product Title:** Northern Light and Star Chasing Guidance Shiny App

## **Product Purpose:**

The main purpose of our app is to provide a user-friendly website that makes it easier for users to plan their trip to Cook County, Minnesota for Northern Light and star chasing. Cook County is the best place in the state of Minnesota to view the Northern Lights and the Northern Light and Star Chasing Guidance app will provide users with all the necessary information they need including the campsites, lookout viewpoints, and visibility related information in order to have the best chance to view the Northern Lights, planets and stars based off their approximate location. In addition, the app will act as a trip planning tool as well with northern lights, weather, and cloud coverage forecast that will allow the user to determine the best time within the next few weeks to plan their trip. 

## **App Availability:**

The app can be publicly accessible via shinyapps.io since the data is public, but we were having difficulty getting the app to publish on shinyapps.io. 


## **Data Sources:**

We will be using publicly available data sources for our app, including geographic features and stored information from Google Maps and aurora forecasts from NOAA. The star and planetary data is from The Stellarium Web online planetarium that runs off open source data from the Stellarium Web Engine Project. 

## **Product Features:**

The main elements of our data product includes an interactive map showing the spots to gaze at the Northern Lights with specific viewpoints and campsites by longitude and latitude. and an interactive map that displays planetary and star visibility information based off the user’s approximate location. We also included plots showing the three day KP levels, a KP level forecast for 27 days, radio blackout forecast, electrical storm forecast, the planetary visibility forecast, and the local weather for the upcoming week. These features will provide users with the necessary information they need to plan their trip and enjoy viewing the Northern Lights and celestial night sky. These features answer the questions regarding if it will be a good time to visit county to see the northern lights, what the cloud coverage will be like, what the KP levels will be for optimal viewing at lower altitudes, what the energy levels in the atmosphere will be for optimal northern lights, what planets, deep space objects, and stars will be viewable, as well. 

## **Automation:**

We extracted data from the source websites like Google Maps, NOAA, and The Stellarium Web Engine Project. Updating of source sites will trigger updates on the app. 

## **Interactivity:**

The app will allow users to check the information of landmarks on the map by clicking and moving the cursor. They will also be able to check the information of aurora forecast, night stars, planet visibility and weather by entering their approximate location and additionally opening the KP forecast and weather tabs. Selecting the KP forecast and weather tabs on the top left of the app will bring users to the Weather website where they can enter in their approximate location to view cloud coverage forecast and KP forecast for the next 27 days. Additionally on the main page of the app, The user will be able to use their cursor to zoom in on the Cook County app to find viewpoints and campsites by utilizing the color coded markers on the map that corresponds to the legend in order to find their campsite or viewpoints they would like to explore. Additionally , they can The longitude and latitude coordinates provided in the Cook County map to enter in those coordinates into the input panel that will update the related tables based on their coordinates. This will allow them to click through each tab to look at energy levels in the atmosphere, KP levels for the next three days, radio storm blackouts and electrical storm predictions. Finally, scrolling down to the bottom of the page the user will see the interactive sky map. At the bottom of the map clicking the location button will allow the user to enter in their location or allow the map to retrieve their approximate location. This will update the sky map to what will be visible based on their location that they entered. Additionally, clicking the buttons on the bottom of the sky map will allow them to view a map of the constellations visible, consolation art, deep sky objects, Change the view of the atmosphere, add landscape to the frame, add different types of grids to the night sky, or change to night viewing mode. Selecting the planets tonight button on the upper left will allow the user to look at planetary visibility For their approximate location. Finally, utilizing the search engine at the top of the star map will allow users to look for specific stars, constellations, and deep sky objects within the sky map. This will update the sky map to show specifically where that searched for object is and will provide information regarding visibility, and other basic information about the object.      

## **Programming Challenges:**

The main programming challenges we encountered were getting the coordinates into the Cook county map, extracting the data from the NOAA and weather forecast websites, and combining that information onto the main page.  

## **Division of Labor:**

Ashley was responsible for the Cook County map and interactive star map. Yansong was responsible for all aurora related functions including the tables, the forecast pages, and the coordinates tab. They worked together on the design, the UI, and the server. 

## **Future Work:**
If we had time, we would like to get the latitude and longitude table to update all of the Maps and tables instead of having the user enter and their location several times throughout the app. Additionally, the background was the NASA photo of the day That gets updated every day by NASA and features astrophotography. If we had time we would like to get this feature to automatically update as the day changes to correspond to the photo of the day. 

## **Reference links:**

1.  The stellarium web page: <https://stellarium-web.org/p/observations>
2.  The stellarium project: <https://github.com/Stellarium/stellarium-web-engine>
3.  NOAA website: <https://www.noaa.gov/>
4.  Aurora forecast extract sample: <https://github.com/calabresemic/aurora-api/blob/main/auroranoaa/__init__.py>
5.  Weather data (api) : <https://www.visualcrossing.com/weather-api?ga_api10=&gclid=CjwKCAjw5pShBhB_EiwAvmnNV8djkVg-Bik7ToFYP-aolivnTTMLBJRIV47OoiWW8Ris0yBlKG8eHRoCIB0QAvD_BwE>
