//
//  ApiService.swift
//  VideoDownloader
//
//  Created by DREAMWORLD on 09/03/26.
//

import Foundation
import SwiftUI

var baseApi = WebService.apiPrefixUrl

struct ApiService {
    static let upcomingMovies = baseApi + "https://api.themoviedb.org/3/movie/upcoming"
    static let popularMovies = baseApi + "https://api.themoviedb.org/3/movie/popular"
    static let popularTvShows = baseApi + "https://api.themoviedb.org/3/tv/popular"
    static let searchMovies = baseApi + "https://api.themoviedb.org/3/search/movie"
    static let topRatedMovies = baseApi + "https://api.themoviedb.org/3/movie/top_rated"
    static let movieGenreList = baseApi + "https://api.themoviedb.org/3/genre/movie/list"
   
    
    // MARK: Movie Detail
    static let movieDetail = baseApi + "https://api.themoviedb.org/3/movie/"
    
    
    // MARK: TV Show Detail
    static let tvSeriesDetail = baseApi + "https://api.themoviedb.org/3/tv/"
    
    
    // MARK: Cast
    static let castDetail = baseApi + "https://api.themoviedb.org/3/person/"
    static let searchPerson = baseApi + "https://api.themoviedb.org/3/search/person"
    static let celebrityList = baseApi + "https://api.themoviedb.org/3/person/popular"
    static let castSearch = baseApi + "https://api.themoviedb.org/3/search/person"
    
    
    // MARK: Movie Providers
    static let movieProviders = baseApi + "https://api.themoviedb.org/3/watch/providers/movie"
    static let providerRigions = baseApi + "https://api.themoviedb.org/3/watch/providers/regions"
    
    // MARK: Discover Movies
    static let discoverMovies = baseApi + "https://api.themoviedb.org/3/discover/movie"
}
