jade = require 'jade'
fs = require 'fs'

Polyglot = require 'node-polyglot'
Instance = require '../models/cozy_instance'

class LocalizationManager

    polyglot: null

    # should be run when app starts
    initialize: (callback = () ->) ->
        @retrieveLocale (err, locale) =>
            if err?
                @polyglot = @getPolyglotByLocale null
            else
                @polyglot = @getPolyglotByLocale locale
            callback null, @polyglot

    retrieveLocale: (callback) ->
        Instance.getLocale (err, locale) ->
            if err? or not locale then locale = 'en' # default value
            callback null, locale

    getPolyglotByLocale: (locale) ->
        if locale?
            try
                phrases = require "../locales/#{locale}"
            catch err
                phrases = require '../locales/en'
        else
            phrases = require '../locales/en'
        return new Polyglot locale: locale, phrases: phrases

    # execute polyglot.t, for server-side localization
    t: (key, params = {}) -> return @polyglot?.t key, params

    getEmailTemplate: (name) ->
        if @polyglot?
            filePath = "../views/#{@polyglot.currentLocale}/#{name}"
            templatefile = require('path').join __dirname, filePath
            return jade.compile fs.readFileSync templatefile, 'utf8'
        else
            return null

    # for template localization
    getPolyglot: -> return @polyglot

module.exports = LocalizationManager
