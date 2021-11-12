{Html5QrcodeScanner} = require "html5-qrcode"
# generate = require "./qrcode.min.js"
# import "./qrcode.min.js"

# console.log "./qrcode.min.js"

if Meteor.isClient
    Router.route '/scanner', -> @render 'scanner'

    Template.scanner.onCreated ->
        @autorun -> Meteor.subscribe 'scanner_products', ->
        @autorun -> Meteor.subscribe 'cart_items', ->
        @autorun -> Meteor.subscribe 'shopping_carts', ->
    Template.scanner.helpers
        selected_cart: -> Session.get('selected_cart_id')
        shopping_cart_button_class:->
            if Session.equals('selected_cart_id',@_id) then 'blue large' else 'basic'
        shopping_cart_docs: ->
            Docs.find 
                model:'shopping_cart'
        test_products: ->
            Docs.find 
                model:'product'
        cart_items: ->
            Docs.find 
                cart_id:Session.get('selected_cart_id')
                model:'cart_item'
    Template.scanner.events
        "click .select_cart": (e,t)->
            if Session.equals('selected_cart_id',@_id)
                Session.set('selected_cart_id', null)
            else 
                Session.set('selected_cart_id', @_id)
        "click .new_cart": (e,t)->
            title = prompt('customer name?')
            if title 
                Docs.insert 
                    model:'shopping_cart'
                    name:title
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
        # 'click .add_code': ->
        #     t.qrcode.makeCode("http://naver.com")
            
        "click .stop": (e,t)->
            $('#reader').empty()
            # t.html5QrcodeScanner.stop().then((ignore)->
            #   console.log 'stopped'
            # ).catch((err) =>
            # );
            
        "click .start": ()->
            # console.log 'generate', generate
            # qrScanner = new QrScanner(this.videoElem, result => console.log('decoded qr code:', result));
            
            console.log(Html5QrcodeScanner);
            
            onScanSuccess = (decodedText, decodedResult)->
                console.log("Code found = #{decodedText}")
                if Session.get('selected_cart_id')
                    found_product = 
                        Docs.findOne 
                            model:'product'
                            title:decodedText
                            
                    if found_product
                        console.log 'found product', found_product
                        existing_cart_item = 
                            Docs.findOne 
                                model:'cart_item'
                                product_title:found_product.title
                                cart_id:Session.get('selected_cart_id')
                        if existing_cart_item
                            Docs.update existing_cart_item._id, 
                                $inc:amount:1
                            $('body').toast(
                                showIcon: 'plus'
                                # message: "#{decodedText} amount increased"
                                message: "#{decodedText} already added"
                                # showProgress: 'bottom'
                                class: 'info'
                                # displayTime: 'auto',
                                position: "top right"
                            )
                        else
                            Docs.insert 
                                model:'cart_item'
                                cart_id:Session.get('selected_cart_id')
                                product_id:found._id
                                product_title:found.title
                                product_image_id:found.image_id
                                amount:1
                            $('body').toast(
                                showIcon: 'cart plus'
                                message: "#{decodedText} added to cart"
                                # showProgress: 'bottom'
                                class: 'success'
                                # displayTime: 'auto',
                                position: "top right"
                            )
                    else 
                        console.log 'No found product'
                else 
                    $('body').toast(
                        showIcon: 'cart plus'
                        message: "#{decodedText} detected but no shopping cart"
                        # showProgress: 'bottom'
                        class: 'error'
                        # displayTime: 'auto',
                        position: "top right"
                    )

                    
            onScanFailure = (error)->
            # //   console.warn(`Code scan error = ${error}`);
            
            html5QrcodeScanner = new Html5QrcodeScanner(
                "reader",
                { fps: 5, qrbox: {width: 300, height: 300} },
                false);
            html5QrcodeScanner.render(onScanSuccess, onScanFailure);
        
        
if Meteor.isServer 
    Meteor.publish 'scanner_products', ->
        Docs.find(
            model:'product'
            app:'nf'
        , limit:10)
        
    Meteor.publish 'cart_items', ->
        Docs.find(
            model:'cart_item'
            app:'nf'
            # product_title:$exists:true
        , {limit:10, sort:'_timestamp':-1})
        
    Meteor.publish 'shopping_carts', ->
        Docs.find(
            model:'shopping_cart'
            # app:'nf'
            # product_title:$exists:true
        , {limit:10, sort:'_timestamp':-1})
        
        