import { polyfill } from 'es6-promise'
polyfill()

import Vue from 'vue/dist/vue.esm'
import Vuex from 'vuex/dist/vuex.esm'

Vue.use(Vuex)

// create store
export default new Vuex.Store({
  state: {
    totalItems: [], // contains project objects
    activeItems: [], // contains indices of articles which match the filters
    currentPage: 1,
    selectedFilterOptions: [], // an array containing an object for each filter that has an array of selected options
    modalContent: {},
    sortDirection: ''
  },

  mutations: {
    updateTotalItems (state, total) {
      this.state.totalItems = total 
    },

    updateActiveItems (state, item) {
      this.state.activeItems.push(item)
    },

    clearActiveItems () {
      this.state.activeItems = []
    },
    
    updateCurrentPage (state, currentPage) {
      this.state.currentPage = currentPage
    },

    updateFilterOptions (state, options) {
      this.state.selectedFilterOptions = options
    },

    addFilterOption (state, option) {
      this.state.selectedFilterOptions.forEach(filter => {
        if(filter.name == option.name){ filter.options.push(option.option)}
      })
    },

    clearFilterOptions () {
      this.state.selectedFilterOptions.forEach(filter => {
        filter.options = []
      })
    },

    removeFilterOption (state, removeOption) {

      this.state.selectedFilterOptions.forEach(filter => {
        if(filter.name == removeOption.name){ 
          filter.options.forEach(option => {
            if(option == removeOption.option){
              const index = filter.options.indexOf(removeOption.option)

              filter.options.splice(index, 1)
            }
          })
        }
      })
    },

    updateModalContent (state, content) {
      this.state.modalContent = content
    },

    updateSortDirection (state, direction) {
      this.state.sortDirection = direction
    }
  }
})
