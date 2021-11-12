{Html5QrcodeScanner} = require "html5-qrcode"
# generate = require "./qrcode.min.js"
# import "./qrcode.min.js"

# console.log "./qrcode.min.js"

if Meteor.isClient
    Router.route '/scanner', -> @render 'scanner'

    Template.scanner.onCreated ->
        @autorun -> Meteor.subscribe 'scanner_products', ->
    Template.scanner.helpers
        test_products: ->
            Docs.find 
                model:'product'
    Template.scanner.events
        "click .gen_code": (e,t)->
            console.log @
            t.qrcode = new QRCode(document.getElementById("qrcode"), {
                text: @title,
                width: 250,
                height: 250,
                colorDark : "#000000",
                colorLight : "#ffffff",
                correctLevel : QRCode.CorrectLevel.H
            })
        
        'click .clear_code': (e,t)-> 
            $('#qrcode').empty()
            console.log t
            t.qrcode.clear()
        'click .add_code': ->
            t.qrcode.makeCode("http://naver.com")
            
        "click .start": ()->
            # console.log 'generate', generate
            # qrScanner = new QrScanner(this.videoElem, result => console.log('decoded qr code:', result));
            
            console.log(Html5QrcodeScanner);
            
            onScanSuccess = (decodedText, decodedResult)->
                console.log("Code matched = #{decodedText}", decodedResult)
                $('body').toast(
                    showIcon: 'cart plus'
                    message: "#{decodedText}, #{decodedResult} detected"
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
        
        
if Meteor.isServer 
    Meteor.publish 'scanner_products', ->
        Docs.find(
            model:'product'
            # app:'nf'
        , limit:5)