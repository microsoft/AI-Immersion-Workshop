Azure ML hands-on lab
=====================

Lab Info and prep
-----------------

### Pre-reqs: (done by the team prior to the session)

1.  Azure Pass

2.  Account information to access Azure

3.  Pre-provisioned Windows DSVM with login information

### Set up steps:

1.  Log in to Azure portal (<https://portal.azure.com>) using the provided account

    1.  Provision Azure ML Workspace

        1.  Click +New, search for Machine Learning Workspace and click to create

            1.  Enter a name

            2.  Resource Group -&gt; Create New -&gt; enter name

            3.  Location -&gt; US South Central

            4.  Storage Account -&gt; Create New -&gt; enter name

            5.  Workspace pricing tier -&gt; Standard

            6.  Web Service plan -&gt; Create New -&gt; enter name

            7.  Web service pricing tier -&gt; DevTest Standard (gray color)

            8.  Click on the Link to Machine Learning Studio

    2.  Connect to the DSVM and log in

        1.  Open the left menu

        2.  Under Compute -&gt; Virtual Machines

        3.  Click on Windows DSVM

        4.  Click on Connect in the top menu

        5.  Open the downloaded file

        6.  Click Connect

        7.  Enter credentials to sign in

        8.  Open Visual Studio 2015 (on the top)

    3.  Visual Studio 2015

        1.  Click Sign in

        2.  Enter credentials (use same account used for Azure)

Lab Script
----------

1.  Click on IE Icon called Sample Gallery on desktop (<https://gallery.cortanaintelligence.com/>)

2.  Get the experiment

    1.  Search for “Predictive Experiment - Mini Twitter” without the quotes

    2.  Click Open in Studio

    3.  Click OK to Copy Experiment

    4.  Click OK (…upgraded)

3.  Review the experiment (Presenter will talk thru - no audience action taken here)

    1.  Visualize import data

    2.  Check Select Columns

    3.  View R Script

    4.  Edit Metadata

    5.  Feature Hashing

    6.  Saved trained model

    7.  Score model

    8.  Execute R Score thresholds

    9.  Web Service output

    10. Web service input

4.  Update the experiment and run in Workspace

    1.  Connect Select Columns to Execute R

    2.  Click Text Analytics in the left menu

    3.  Add Detect Languages

        1.  Drag “Detect Languages” module to the surface

        2.  Connect the Execute R module’s left output to this new module

        3.  Click on Detect Languages, then click Launch Column Selector from right menu

        4.  Select column name in the drop-down (if not selected)

        5.  Type "tweet\_text" and click ok

    4.  Add Extract Key Phrases module

        1.  Drag “Extract Key Phrases from Text” module to the surface

        2.  Connect Execute R module’s left output to this new module

        3.  Click on the module, then click Launch Column Selector from right menu

        4.  Select Column name in the second drop-down

        5.  Type "tweet\_text" and click ok

    5.  In the left nav menu, select Web Service

        1.  Add Web Service output to each of the two new modules

        2.  Attached their output to the modules

    6.  Click Run

5.  Deploy Web Service

    1.  Click New \[Preview\]

    2.  Select Plan

    3.  Click Deploy

6.  Discuss Belize UI and Web Services list (no attendee action, just a review)

    1.  Go through the menu

7.  Test

    1.  Click Test on the top menu

    2.  Type a sample text "I love the build conference in Seattle"

8.  Build a client console app

    1.  Copy the sample C\# code

    2.  Open Visual Studio

        1.  Click File -&gt; New -&gt; Project-&gt; Under Templates, Visual C\# -&gt; Console App

        2.  Type "CallRequestResponseService"

        3.  Click OK

        4.  Paste the code

        5.  In line 35, enter "I hate standing in lines" for "tweet\_text"

        6.  Enter the API key

        7.  Switch to AML UI

        8.  Copy the Key in the code for "apikey" in line 46

        9.  Paste in code

        10. Install the Nuget package mentioned in comments at the top of the code

        11. In the "response.IsSuccessStatusCode" after the second line (64), enter “Console.ReadLine();” without the quote

        12. Run the app, and note the results

9.  Build web app using template (to share API with others)

    1.  Find the template

        1.  Open browser

        2.  Go to <https://aka.ms/rrstemplate>

    2.  Build the app

        1.  Click "Get it Now" and "Continue"

        2.  In the Azure Portal, under Create

            1.  Type in the App name

            2.  Check Pin to dashboard on the bottom

            3.  Then click Create

        3.  When done, click on the URL (Top right corner)

            1.  If can’t find it, click on Dashboard in the left menu, then click on the App name to open it, the click on URL

        4.  Switch to the AML UI, and copy the RRS URL

        5.  Paste into the app's first input

        6.  Repeat for API Key

        7.  Make sure “Sentiment” is checked in output

        8.  Click Save Changes

        9.  Then Go to home page

    3.  Run the app

        1.  Enter a text "Azure ML is easy to use."

        2.  Then click run


