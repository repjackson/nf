{Html5QrcodeScanner} = require "html5-qrcode"
# generate = require "./qrcode.min.js"
# import "./qrcode.min.js"

# console.log "./qrcode.min.js"

if Meteor.isClient
    Router.route '/scanner', -> @render 'scanner'

    Template.scanner.onCreated ->
        @autorun -> Meteor.subscribe 'scanner_products', ->
        @autorun -> Meteor.subscribe 'cart_items', ->
    Template.scanner.helpers
        test_products: ->
            Docs.find 
                model:'product'
        cart_items: ->
            Docs.find 
                model:'cart_item'
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
        
        'click .remove_cart_item': (e,t)-> 
            if confirm "remove #{@title}?"
                Docs.remove @_id
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
                console.log("Code found = #{decodedText}")
                $('body').toast(
                    showIcon: 'cart plus'
                    message: "#{decodedText} added to cart"
                    # showProgress: 'bottom'
                    class: 'success'
                    # displayTime: 'auto',
                    position: "bottom right"
                )
                found = 
                    Docs.findOne 
                        title:decodedText
                if found
                    Docs.insert 
                        model:'cart_item'
                        product_id:found._id
                        product_title:found.title
                        product_image_id:found.image_id
            
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
        
    Meteor.publish 'cart_items', ->
        Docs.find(
            model:'cart_item'
            app:'nf'
            # product_title:$exists:true
        , {limit:10, sort:'_timestamp':-1})
        
        