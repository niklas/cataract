Object.extend = function(destination) {
    $A(arguments).slice(1).each(function (src) {
        for (var property in src) {
            destination[property] = src[property];
        }
    })
    return destination
}

Object.merge = function() {
    return Object.extend.apply(this, [{}].concat($A(arguments)))
}

var Hobo = {

    searchRequest: null,
    uidCounter: 0,
    ipeOldValues: {},
    spinnerMinTime: 1000, // milliseconds 

    uid: function() {
        Hobo.uidCounter += 1
        return "uid" + Hobo.uidCounter
    },

    updatesForElement: function(el) {
        el = $(el)
        var updates = el.getAttribute("hobo-update")
        return updates ? updates.split(/\s*,\s*/) : []
    },

    ajaxSetFieldForElement: function(el, val, options) {
        var updates = Hobo.updatesForElement(el)
        var params = Hobo.fieldSetParam(el, val)
        var p = el.getAttribute("hobo-ajax-params")
        if (p) params = params + "&" + p

        var opts = Object.merge(options || {}, { params: params})
        Hobo.ajaxRequest(Hobo.putUrl(el),
                         el.getAttribute("hobo-ajax-message") || "Changing...",
                         updates,
                         opts)
    },

    ajaxUpdateParams: function(updates, resultUpdates) {
        var params = []
        var i = 0
        if (updates.length > 0) {
            updates.each(function(id_or_el) {
                var el = $(id_or_el)
                if (el) { // ignore update of parts that do not exist
                    var partDomId
                    partDomId = el.id
                    if (!hoboParts[partDomId]) { throw "Update of dom-id that is not a part: " + partDomId }
                    params.push("render["+i+"][part_context]=" + encodeURIComponent(hoboParts[partDomId]))
                    params.push("render["+i+"][id]=" + partDomId)
                    i += 1
                }
            })
            params.push("page_path=" + hoboPagePath)
        }

        if (resultUpdates) {
            resultUpdates.each(function (resultUpdate) {
                params.push("render["+i+"][id]=" + resultUpdate.id)
                params.push("render["+i+"][result]=" + resultUpdate.result)
                if (resultUpdate.func) {
                    params.push("render["+i+"][function]=" + resultUpdate.func)
                }
                i += 1
            })
        }
        return params.join('&')
    },

    ajaxRequest: function(url_or_form, message, updates, options) {
        options = Object.merge({ asynchronous:true,
                                 evalScripts:true,
                                 resetForm: false,
                                 refocusForm: false
                               }, options)
        if (typeof url_or_form == "string") {
            var url = url_or_form
            var form = false
        } else {
            var form = url_or_form
            var url = form.action
        }
        var params = []

        if (typeof(formAuthToken) != "undefined") {
            params.push(formAuthToken.name + "=" + formAuthToken.value)
        }
        
        updateParams = Hobo.ajaxUpdateParams(updates, options.resultUpdate)
        if (updateParams != "") { params.push(updateParams) }

        if (options.params) {
            params.push(options.params)
            delete options.params
        }

        if (form) {
            params.push(Form.serialize(form))
        }

        Hobo.showSpinner(message, options.spinnerNextTo)
        var complete = function() {
            if (form && options.resetForm) form.reset();
            Hobo.hideSpinner();

            if (options.onComplete)
                options.onComplete.apply(this, arguments)
            if (form && options.refocusForm) Form.focusFirstElement(form)
        }
        if (options.method && options.method.toLowerCase() == "put") {
            delete options.method
            params.push("_method=PUT")
        }

        if (!options.onFailure) {
            options.onFailure = function(response) {
                alert(response.responseText)
            }
        }

        new Ajax.Request(url, Object.merge(options, { parameters: params.join("&"), onComplete: complete }))
    },

    hide: function() {
        for (i = 0; i < arguments.length; i++) {
            if ($(arguments[i])) {
                Element.addClassName(arguments[i], 'hidden')
            }
        }
    },

    show: function() {
        for (i = 0; i < arguments.length; i++) {
            if ($(arguments[i])) {
                Element.removeClassName(arguments[i], 'hidden')
            }
        }
    },

    toggle: function() {
        for (i = 0; i < arguments.length; i++) {
            if ($(arguments[i])) {
                if(Element.hasClassName(arguments[i], 'hidden')) {
                    Element.removeClassName(arguments[i], 'hidden')
                } else {
                    Element.addClassName(arguments[i], 'hidden')
                }
            }
        }
        },

    onFieldEditComplete: function(el, newValue) {
        el = $(el)
        var oldValue = Hobo.ipeOldValues[el.id]
        delete Hobo.ipeOldValues[el.id]

        var blank = el.getAttribute("hobo-blank-message")
        if (blank && newValue.strip().length == 0) {
            el.update(blank)
        } else {
            el.update(newValue)
        }

        var modelId = el.getAttribute('hobo-model-id')
        if (oldValue) {
            $$("*[hobo-model-id=" + modelId + "]").each(function(e) {
                if (e != el && e.innerHTML == oldValue) e.update(newValue)
            })
        }
    },

    _makeInPlaceEditor: function(el, options) {
        var old
        var spec = Hobo.parseFieldId(el)
        var updates = Hobo.updatesForElement(el)
        var id = el.id
        if (!id) { id = el.id = Hobo.uid() }
        var updateParams = Hobo.ajaxUpdateParams(updates, [{id: id,
                                                            result: 'new_field_value',
                                                            func: "Hobo.onFieldEditComplete"}])
        opts = {okButton: false,
                cancelLink: false,
                submitOnBlur: true,
                evalScripts: true,
                htmlResponse: false,
                ajaxOptions: { method: "put" },
                onEnterHover: null,
                onLeaveHover: null,
                callback: function(form, val) {
                    old = val
                    return (Hobo.fieldSetParam(el, val) + "&" + updateParams)
                },
                onFailure: function(resp) { 
                    alert(resp.responseText); el.innerHTML = old
                },
                onEnterEditMode: function() {
                    var blank_message = el.getAttribute("hobo-blank-message")
                    if (el.innerHTML.gsub("&nbsp;", " ") == blank_message) {
                        el.innerHTML = "" 
                    } else {
                        Hobo.ipeOldValues[el.id] = el.innerHTML
                    }
                }
               }
        Object.extend(opts, options)
        return new Ajax.InPlaceEditor(el, Hobo.putUrl(el), opts)
    },

    applyEvents: function(root) {
        root = $(root)
        function select(p) {
            return new Selector(p).findElements(root)
        }

        select(".in-place-textfield-bhv").each(function (el) {
            ipe = Hobo._makeInPlaceEditor(el)
            ipe.getText = function() {
                return this.element.innerHTML.gsub(/<br\s*\/?>/, "\n").unescapeHTML()
            }
        })

        select(".in-place-textarea-bhv").each(function (el) {
            ipe = Hobo._makeInPlaceEditor(el, {rows: 2})
            ipe.getText = function() {
                return this.element.innerHTML.gsub(/<br\s*\/?>/, "\n").unescapeHTML()
            }
        })

        select(".in-place-html-textarea-bhv").each(function (el) {
            var options = {rows: 2, handleLineBreaks: false}
            if (typeof(tinyMCE) != "undefined") options["submitOnBlur"] = false
            var ipe = Hobo._makeInPlaceEditor(el, options) 
            if (typeof(tinyMCE) != "undefined") {
                ipe.afterEnterEditMode = function() {
                    var id = this.form.id = Hobo.uid()

                    // 'orrible 'ack
                    // What is the correct way to individually configure a tinyMCE instace?
                    var old = tinyMCE.settings.theme_advanced_buttons1
                    tinyMCE.settings.theme_advanced_buttons1 += ", separator, save"
                    tinyMCE.addMCEControl(this.editField, id);
                    tinyMCE.settings.theme_advanced_buttons1 = old

                    this.form.onsubmit = function() {
                        tinyMCE.removeMCEControl(ipe.form.id)
                        setTimeout(ipe.onSubmit.bind(ipe), 10)
                        return false
                    }
                }
            }
        })

        select("select.number-editor-bhv").each(function(el) {
            el.onchange = function() {
                Hobo.ajaxSetFieldForElement(el, el.value)
            }
        })
                                                
        select(".autocomplete-bhv").each(function (el) {
            options = {paramName: "query", minChars: 3, method: 'get' }
            if (el.hasClassName("autosubmit")) {
                options.afterUpdateElement = function(el, item) { el.form.onsubmit(); }
            }
            new Ajax.Autocompleter(el, el.id + "-completions", el.getAttribute("autocomplete-url"),
                                   options);
        });

        select(".search-bhv").each(function(el) {
            new Form.Element.Observer(el, 1.0, function() { Hobo.doSearch(el) })
        });
    },


    doSearch: function(el) {
        el = $(el)
        var spinner = $(el.getAttribute("search-spinner") || "search-spinner")
        var search_results = $(el.getAttribute("search-results") || "search-results")
        var search_results_panel = $(el.getAttribute("search-results-panel") || "search-results-panel")
        var url = el.getAttribute("search-url") || (urlBase + "/search")

        el.focus();
        var value = $F(el)
        if (Hobo.searchRequest) { Hobo.searchRequest.transport.abort() }
        if (value.length >= 3) {
            if (spinner) Hobo.show(spinner);
            Hobo.searchRequest = new Ajax.Updater(search_results,
                                                  url,
                                                  { asynchronous:true,
                                                    evalScripts:true,
                                                    onSuccess:function(request) {
                                                        if (spinner) Hobo.hide(spinner)
                                                        if (search_results_panel) {
                                                            Hobo.show(search_results_panel)
                                                        }
                                                        setTimeout(function() {Hobo.applyEvents(search_results)}, 1)
                                                    },
                                                    method: "get",
                                                    parameters:"query=" + value });
        } else {
            Hobo.updateElement(search_results, '')
            Hobo.hide(search_results_panel)
        }
    },


    putUrl: function(el) {
        spec = Hobo.parseFieldId(el)
        return urlBase + "/" + Hobo.pluralise(spec.name) + "/" + spec.id + "?_method=PUT"
    },

        
    fieldSetParam: function(el, val) {
        spec = Hobo.parseFieldId(el)
        res = spec.name + '[' + spec.field + ']=' + encodeURIComponent(val)
        if (typeof(formAuthToken) != "undefined") {
            res = res + "&" + formAuthToken.name + "=" + formAuthToken.value
        }
        return res
    },

    fadeObjectElement: function(el) {
        new Effect.Fade(Hobo.objectElementFor(el),
                        { duration: 0.5,
                          afterFinish: function (ef) { ef.element.remove() } });
    },

    removeButton: function(el, url, updates, options) {
        if (options.fade == null) { options.fade = true; }
        if (options.confirm == null) { options.fade = "Are you sure?"; }

        if (options.confirm == false || confirm(options.confirm)) {
            objEl = Hobo.objectElementFor(el)
            Hobo.showSpinner('Removing');
            function complete() {
                if (options.fade) { Hobo.fadeObjectElement(el) }
                Hobo.hideSpinner()
            }
            if (updates && updates.length > 0) {
                new Hobo.ajaxRequest(url, "Removing", updates, { method:'delete',
                                                                 onComplete: complete});
            } else {
                new Ajax.Request(url, {asynchronous:true, evalScripts:true, method:'delete',
                                       onComplete: complete});
            }
        }
    },


    parseFieldId: function(el) {
        id = el.getAttribute("hobo-model-id")
        if (!id) return
        m = id.match(/^([a-z_]+)_([0-9]+)_([a-z_]+)$/)
        if (m) return { name: m[1], id: m[2], field: m[3] }
    },

    appendRow: function(el, rowSrc) {
        // IE friendly method to add a <tr> (from html source) to a table
        // el should be an element that contains *only* a table
        el = $(el);
        el.innerHTML = el.innerHTML.replace("</table>", "") + rowSrc + "</table>";
        Hobo.applyEvents(el)
    },

    objectElementFor: function(el) {
        var m
        while(el.getAttribute) {
            id = el.getAttribute("hobo-model-id");
            if (id) m = id.match(/^([a-z_]+)_([0-9]+)(_[a-z0-9_]*)?$/);
            if (m) break;
            el = el.parentNode;
        }
        if (m) return el;
    },


    showSpinner: function(message, nextTo) {
        clearTimeout(Hobo.spinnerTimer)
        Hobo.spinnerHideAt = new Date().getTime() + Hobo.spinnerMinTime;
        if(t = $('ajax-progress-text')) Element.update(t, message);
        if(e = $('ajax-progress')) {
            if (nextTo) {
                var pos = nextTo.cumulativeOffset()
                e.style.top = pos.top + "px"
                e.style.left = (pos.left + nextTo.offsetWidth) + "px"
            }
            e.style.display = "block";
        }
    },


    hideSpinner: function() {
        if (e = $('ajax-progress')) {
            var remainingTime = Hobo.spinnerHideAt - new Date().getTime()
            if (remainingTime <= 0) {
                e.visualEffect('Fade')
            } else {
                Hobo.spinnerTimer = setTimeout(function () { e.visualEffect('Fade') }, remainingTime)
            }
        }
    },


    updateElement: function(id, content) {
        Element.update(id, content)
        Hobo.applyEvents(id)
    },

    getStyle: function(el, styleProp) {
        if (el.currentStyle)
            var y = el.currentStyle[styleProp];
        else if (window.getComputedStyle)
            var y = document.defaultView.getComputedStyle(el, null).getPropertyValue(styleProp);
        return y;
    },

    partFor: function(el) {
        while (el) {
            if (el.id && hoboParts[el.id]) { return el }
            el = el.parentNode
        }
        return null
    },

    pluralise: function(s) {
        return pluralisations[s] || s + "s"
    },

    addUrlParams: function(params) {
        params = $H(window.location.search.toQueryParams()).merge(params)
        return window.location.href.sub(/(\?.*|$)/, "?" + params.toQueryString())
    }


}

Element.findContaining = function(el, tag) {
    el = $(el)
    tag = tag.toLowerCase()
    e = el.parentNode
    while (el) {
        if (el.nodeName.toLowerCase() == tag) {
            return el;
        }
        e = el.parentNode
    }
    return null;
}

// Add an afterEnterEditMode hook to in-place-editor
origEnterEditMode = Ajax.InPlaceEditor.prototype.enterEditMode
Ajax.InPlaceEditor.prototype.enterEditMode = function(evt) {
    origEnterEditMode.bind(this)(evt)
    if (this.afterEnterEditMode) this.afterEnterEditMode()
    return false
}

// Fix Safari in-place-editor bug
Ajax.InPlaceEditor.prototype.removeForm = function() {
    if (!this._form) return;
    
    if (this._form.parentNode) { try { Element.remove(this._form); } catch (e) {}}    
    this._form = null;
    this._controls = { };
}

// Silence errors from IE :-(
Field.scrollFreeActivate = function(field) {
  setTimeout(function() {
      try {
          Field.activate(field);
      } catch(e) {}
  }, 1);
}


Element.Methods.$$ = function(e, css) {
    return new Selector(css).findElements(e)
}

// --- has_many_through_input --- //

HasManyThroughInput = Behavior.create({

    initialize : function() {
        // onchange doesn't bubble in IE6 so...
        Event.observe(this.element.down('select'), 'change', this.addOne.bind(this))
    },

    addOne : function() {
        var select = this.element.down('select')
        var selected = select.options[select.selectedIndex]
        if (selected.style.display != "none" & selected.value != "") {
            var newItem = strToDom(this.element.down('.item-proto').innerHTML)
            this.element.down('.items').appendChild(newItem);
            newItem.down('span').innerHTML = selected.innerHTML
            newItem.down('input[type=hidden]').value = selected.innerHTML
            selected.style.display = 'none'
            select.value = ""
        }
    },

    onclick : function(e) {
        var el = Event.element(e);
        Event.stop(e);
        if (el.match(".remove-item")) { this.removeOne(el.parentNode) }
    },

    removeOne : function(el) {
        new Effect.BlindUp(el, 
                           { duration: 0.3,
                             afterFinish: function (ef) { ef.element.remove() } } ) 
        var label = el.down('span').innerHTML
        var option = $A(this.element.getElementsByTagName('option')).find(function(o) { return o.innerHTML == label })
        option.style.display = 'block'
    }

})

Event.addBehavior({
    'div.has-many-through.input' : HasManyThroughInput(),
		'.association-count:click' : function(e) {
			new Effect.ScrollTo('primary-collection', {duration: 1.0, offset: -20, transition: Effect.Transitions.sinoidal});
			Event.stop(e);
		}
});
