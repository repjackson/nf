{Html5QrcodeScanner} = require "html5-qrcode"


if Meteor.isClient
  Router.route '/scanner', -> @render 'scanner'

  Template.scanner.events
      "click .start": ()->
        # qrScanner = new QrScanner(this.videoElem, result => console.log('decoded qr code:', result));
          
        console.log(Html5QrcodeScanner);
        
        onScanSuccess = (decodedText, decodedResult)->
          console.log("Code matched = #{decodedText}", decodedResult)
        
        onScanFailure = (error)->
        # //   console.warn(`Code scan error = ${error}`);
        
        html5QrcodeScanner = new Html5QrcodeScanner(
          "reader",
          { fps: 10, qrbox: {width: 300, height: 300} },
           false);
        html5QrcodeScanner.render(onScanSuccess, onScanFailure);
        