# Magicseaweed Project

**Requirements: Xcode 11 // Mac running MacOS 10.15**

**To Install An API Key:**
Navigate to the file Endpoint.swift / Line 14 in Xcode and paste your Places API Key between the two "" after value:.

> fileprivate let apiKey: URLQueryItem = URLQueryItem(name: "key", value: "YOUR KEY HERE")

Note: Unit tests are in place for this project and will need to be udpated to reflect your API Key. Instructions are within each unit test.

**Once done, Select the Sim you would like to use (Or physical device) and press play to build**

# Notes

There aren't an awful lot of places that appear under the 'lodging' type with the keyword 'surf'. There's one just above Hale on the west coast of the UK, one in Brighton and another on the west coast of the US near LA however I wasn't able to find two within 1km of eachother, which makes it hard to test scalability and will make it quite hard for you guys to test the code. 

I'd recommend adding a second type, campground, to the type query item on line 99 in Endpoint.swift to find a lot more places, and demonstrate this code a tad better. I've left it with just lodging for my submission so that it hits the brief. 

If you want to do that, Line 99 should look like this:

> let typeItem = URLQueryItem(name: "type", value: "lodging, campground")

**Autolayout is in place so that it will resize correctly on any device**

**Unit tests are in place**
