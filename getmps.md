# Finding MPs for each LA using the ONS API

Because I am lazy and I needed the data in Excel, this tutorial covers how to use PowerQuery to download the data (so also appliccable to PowerBI). If you want to use R or Python you will need to find a RESTive API package that deals with panigation. It will probably be a lot easier :)

## Data Sources

We need data on which MP is in which constituency, which we can get from the theyworkforyou API [https://www.theyworkforyou.com/mps/?f=csv](https://www.theyworkforyou.com/mps/?f=csv) (Note that theyworkforyou does actually have an API, and this isn't it, but this is sufficient for us for now).
We also want data on which constituency is in which Local Authority, which is on the ONS Geoportal. The one for 2022 is [here](https://geoportal.statistics.gov.uk/datasets/ons::ward-to-westminster-parliamentary-constituency-to-local-authority-district-to-upper-tier-local-authority-december-2022-lookup-in-the-united-kingdom/about), and this is the dataset I'll use in this tutorial, as it's the most recent one when I'm writing this, but it should soon be out of date, and you should look for a newer version with updated LAs and constituency boundaries.

## Downloading the data

So were done right? Just download the data from each source and then `INDEX/MATCH` / `left_join` them together? WRONG!

There are two problems, one more easily solved than ther other.

1. We need to use the API to download the LA data, but by default it will only download the first 1000 objects. Unfortunately, because the file also contains all of the information on wards as well as constituencies, there are over 9000 datapoints in the file, so we need  a way to get around this.
1. The two inputs are in different formats, the MP data is in a CSV, while the LA data is in a 
