# Tech Debt

This document describes techinical debt that was encountered when translating the SDK from Objective-C to Swift.

## Evaluating JavaScript

#### 2023-04-14
The function `evaluateJavaScript(_:, withRetryAttempts:)` should be replaced.

It's used to call `evaluateJavaScript(_:)` with one second intervals until it succeeds. Those calls fail as long as the `WebView` has not finished navigating. We should probably handle this with delegation or something instead.

## UserDefaults Keys

#### 2023-03-29
The keys for UserDefaults (in Storage.Keys) could be simplified to match the variable they are associated with. It's probably safe to change them at any time, but when translating the app from Objective-C, they were kept as a precaution. Perhaps a better to change them is the next time we implement breaking changes.

## Versioning

#### 2023-03-29
One of the checks made for the backend sync is if the version of the SDK has changed. This is made by checking a `String`, which is hard-coded with the version number. We should find a way to automate this, since it's not obvious that this should be done before publishing a new release. 

## TSMobileAnalyticsSwift / SDKIntegrationValidator

#### 2023-03-16
`SDKIntegrationValidator`´s function `validate(applicationName:, cpid:)` is called from the `init` of `TSMobileAnalyticsSwift`, but doesn't actually affect the initialization process, it only prints anything out of the ordinary and moves on. At the end of the `init`, it still prints that the SDK has been initialized, which isn't necessarily true if the init was called with bad parameters.

We should probably throw an error from the validation function and handle that in the `init`, but this will obviously cause breaking changes.
