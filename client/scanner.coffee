{Html5QrcodeScanner} = require "html5-qrcode"
# generate = require "./qrcode.min.js"
# import "./qrcode.min.js"

# console.log "./qrcode.min.js"

if Meteor.isClient
  Router.route '/scanner', -> @render 'scanner'

  Template.scanner.events
      "click .start": ()->
            qrcode = new QRCode(document.getElementById("qrcode"), {
            	text: "http://jindo.dev.naver.com/collie",
            	width: 128,
            	height: 128,
            	colorDark : "#000000",
            	colorLight : "#ffffff",
            	correctLevel : QRCode.CorrectLevel.H
            })
            # console.log 'generate', generate
            # qrScanner = new QrScanner(this.videoElem, result => console.log('decoded qr code:', result));
            
            console.log(Html5QrcodeScanner);
            
            onScanSuccess = (decodedText, decodedResult)->
                console.log("Code matched = #{decodedText}", decodedResult)
                $('body').toast(
                    showIcon: 'cart plus'
                    message: "#{@title} added"
                    # showProgress: 'bottom'
                    class: 'success'
                    # displayTime: 'auto',
                    position: "bottom right"
                )
            
            onScanFailure = (error)->
            # //   console.warn(`Code scan error = ${error}`);
            
            html5QrcodeScanner = new Html5QrcodeScanner(
                "reader",
                { fps: 10, qrbox: {width: 300, height: 300} },
                false);
            html5QrcodeScanner.render(onScanSuccess, onScanFailure);
        