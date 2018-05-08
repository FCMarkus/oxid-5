<style type="text/css">
    #addressBookWidgetDiv {
        min-width: 300px;
        width: 100%;
        max-width: 900px;
        min-height: 228px;
        height: 240px;
        max-height: 400px;
        [{if $oViewConf->fcpoGetAmazonPayAddressWidgetIsReadOnly()}]
            displayMode: "Read";
        [{/if}]
    }
</style>

<form class="form-horizontal" action="[{$oViewConf->getSslSelfLink()}]" name="order" method="post" novalidate="novalidate">
    [{block name="user_checkout_change_form"}]
        [{assign var="aErrors" value=$oView->getFieldValidationErrors()}]
        [{$oViewConf->getHiddenSid()}]
        [{$oViewConf->getNavFormParams()}]
        <input type="hidden" name="cl" value="payment">
        <input type="hidden" name="option" value="[{$oView->getLoginOption()}]">
        <input type="hidden" name="fnc" value="fcpoAmazonUserLogin">
        <input type="hidden" name="lgn_cook" value="0">
        <input type="hidden" name="blshowshipaddress" value="1">

        [{block name="user_checkout_change_next_step_top"}]
            <div class="well well-sm">
                <a href="[{oxgetseourl ident=$oViewConf->getBasketLink()}]" class="btn btn-default pull-left prevStep submitButton largeButton" id="userBackStepTop"><i class="fa fa-caret-left"></i> [{oxmultilang ident="PREVIOUS_STEP"}]</a>
                <button id="userNextStepTop" class="btn btn-primary pull-right submitButton largeButton nextStep" name="userform" type="submit">[{oxmultilang ident="CONTINUE_TO_NEXT_STEP"}] <i class="fa fa-caret-right"></i></button>
                <div class="clearfix"></div>
            </div>
        [{/block}]

        <div class="panel panel-default">
            <div class="panel-heading"><h3 class="panel-title">[{oxmultilang ident="FCPO_AMAZON_SELECT_ADDRESS"}]</h3></div>
            <div class="panel-body">
                <div id="addressBookWidgetDiv"></div>
                <a href="index.php?cl=basket&fcpoamzaction=logoff">[{oxmultilang ident="FCPO_AMAZON_LOGOFF"}]</a>
            </div>
        </div>
        <script>
            function getURLParameter(name, source) {
                return decodeURIComponent((new RegExp('[?|&|#]' + name + '=' +
                    '([^&]+?)(&|#|;|$)').exec(source) || [,""])[1].replace(/\+/g,
                    '%20')) || null;
            }

            var accessToken = getURLParameter("access_token", location.hash);

            if (typeof accessToken === 'string' && accessToken.match(/^Atza/)) {
                document.cookie = "amazon_Login_accessToken=" + accessToken +
                    ";secure";
            }

            window.onAmazonLoginReady = function() {
                amazon.Login.setClientId('[{$oViewConf->fcpoGetAmazonPayClientId()}]');
                if (typeof accessToken === 'string' && accessToken.match(/^Atza/)) {
                    amazon.Login.setUseCookie(true);
                }
                [{if !$oViewConf->fcpoAmazonLoginSessionActive()}]
                    amazon.Login.logout();
                [{/if}]
            };
            window.onAmazonPaymentsReady = function() {
                new OffAmazonPayments.Widgets.AddressBook({
                    sellerId: '[{$oViewConf->fcpoGetAmazonPaySellerId()}]',
                    scope: 'profile payments:widget payments:shipping_address payments:billing_address',
                    onOrderReferenceCreate: function(orderReference) {
                        orderReferenceId = orderReference.getAmazonOrderReferenceId();
                    },
                    onAddressSelect: function(orderReference) {
                        console.log('triggered onAddressSelect');
                        var formParams = "{";
                                formParams += '"fcpoAmazonReferenceId":"' + orderReferenceId + '"';
                                formParams += "}";
                        $.ajax({
                            url: 'modules/fcPayOne/application/models/fcpayone_ajax.php',
                            method: 'POST',
                            type: 'POST',
                            dataType: 'text',
                            data: { paymentid: "fcpoamazonpay", action: "get_amazon_reference_details", params: formParams },
                            success: function(Response) {
                            }
                        });
                    },
                    design: {
                        designMode: 'responsive'
                    },
                    onReady: function(orderReference) {
                    },
                    onError: function(error) {
                        console.log(error.getErrorCode() + ': ' + error.getErrorMessage());
                    }
                }).bind("addressBookWidgetDiv");
            };
        </script>
        <script async="async" src='[{$oViewConf->fcpoGetAmazonWidgetsUrl()}]'></script>

        <div class="well well-sm">
            <a href="[{oxgetseourl ident=$oViewConf->getBasketLink()}]" class="btn btn-default pull-left prevStep submitButton largeButton" id="userBackStepBottom"><i class="fa fa-caret-left"></i> [{oxmultilang ident="PREVIOUS_STEP"}]</a>
            <button id="userNextStepBottom" class="btn btn-primary pull-right submitButton largeButton nextStep" name="userform" type="submit">[{oxmultilang ident="CONTINUE_TO_NEXT_STEP"}] <i class="fa fa-caret-right"></i></button>
            <div class="clearfix"></div>
        </div>
    [{/block}]
</form>