# Northern Light and Stars Chasing Guidance Shiny App Working Draft

##Update: An interactive leaflet map of Cook County, MN was created using OSMdata and added to the Shiny app, so users can not only use the map as a frame of reference for the County, but will also be able to use the map to find lookout viewpoints that will be helpful for star chasing, but also campsites and hotels where they can stay, as well. Observatories still need to be added, but we were having difficulty adding a second feature to the leaflet code that worked successfully. Our plan is to add observatories and to improve the information that the user gets back when they hover over a map marker. Right now, only the name is displayed. Our goal is to have the name and other basic information for the user to utilize.

We were able to use an R iframe code to input the stellarium open source planetarium website directly into our shiny app. This allows us to be able to utilize the planet visibility functions and night sky map functions from the stellarium website directly on our shiny app. The user can register directly from our shiny app or will be able to utilize the functions without registering. Additionally, they will be able to view the night sky as they should be able to see it by inputting their location into that section of the shiny app and the corresponding stars and constellations will populate. The only concern right now regarding this is making sure it is not taking up too much space on our app, but yet is large enough to remain functional to the user. There is no specific dataset for the stellarium page, but below is the website and the related github page:

Besides the Stellarium part, we used raw JSON data of the 30 minutes Aurora forecast. We were able to make the forecast specific to a certain longitude and altitude. For the 3-day forecast, we captured data from NOAA website and created bar plots to compare the kp values in a 3-day series. And we also provide Radio Blackout Forecast for the latest three days and Solar Radiation Storm Forecast for the latest three days. For the 27-day forecast, we created a button that will direct users directly to the NOAA website. We did not do new statistics summaries because the raw data requires a key to download.

Finally, we created another button for weather forecast that directs users to a cloud map. This allows users to view a map of cloud coverage in their area, which can help them plan their stargazing trip. The cloud map is provided by Windy.com and the link to the map is included in the Shiny app.

To sum up, creating the app presented several challenges that required creative problem-solving. One of the main challenges we faced was integrating the different features of the app, such as tabs, buttons, and the map, into a cohesive user interface. As we combined the original separate functions, the map disappeared, and the layout of the website became unappealing. We had to experiment with different design layouts and strategies to ensure that each feature of the app was easily accessible to the user and did not clutter the user interface. Additionally, we had difficulty integrating the observatories feature into the map, as it required a second feature that was not easily compatible with the current design. However, we continue to work on improving the app's functionality and design to ensure a seamless user experience.

Pictures of separated functions wrapped in apps:

Figure1. Picture of the base map and the Stellarium

![](Working%20Draft%20Screen%20shot%20of%20Shiny%20App2.png)

Figure2. Picture showing the Stellarium visibility

![](Working%20Draft%20Screen%20Shot%20of%20Shiny%20App.png)

Figure3. Picture showing the function of 30 minutes Aurora forecast

![](Screen%20Shot%202023-04-16%20at%2010.55.09%20PM.png)

Figure4. Picture showing the function of 3 day Aurora forecast

![](Screen%20Shot%202023-04-16%20at%2011.31.33%20PM.png)

Figure5. Picture showing the error occurs when combined

![](Screen%20Shot%202023-04-16%20at%2011.26.45%20PM.png)

<https://stellarium-web.org/p/observations>

<https://github.com/Stellarium/stellarium-web-engine.git>
