<template>
  <div class="right">
    <div v-if="haveResults">
      <span class="bold">{{ firstItem }} - {{ lastItem }} of {{ totalItems }}</span>

      <button
        v-bind="{ 'disabled' : !previousIsActive }"
        @click="changePage(previousIsActive, 'previous')"
        class="button button--previous"
        :class="{ 'button--disabled' : !previousIsActive }">
      </button>

      <button
        v-bind="{ 'disabled' : !nextIsActive }"
        @click="changePage(nextIsActive, 'next')"
        class="button button--next"
        :class="{ 'button--disabled' : !nextIsActive }">
      </button>
    </div>

    <div v-else class="left">
      <p>There are no evaluations matching the selected filters options.</p>
    </div>
  </div>
</template>

<script>
  import { eventHub } from '../../home.js'

  export default {
    name: "pagination",

    props: {
      currentPage: {
        required: true,
        type: Number
      },
      itemsPerPage: {
        required: true,
        type: Number
      },
      totalItems: {
        required: true,
        type: Number
      },
      totalPages: {
        required: true,
        type: Number
      }
    },

    computed: {
      nextIsActive () {
        return  this.currentPage < this.totalPages
      },

      previousIsActive () {
        return this.currentPage > 1
      },

      firstItem () {
        let first

        if(this.totalItems == 0) {
          first = 0

        } else if (this.totalItems < this.itemsPerPage) {
          first = 1

        } else {
          first = this.itemsPerPage * (this.currentPage - 1) + 1
        }

        return first
      },

      lastItem () {
        let lastItem = this.itemsPerPage * this.currentPage

        if (lastItem > this.totalItems) {
          lastItem = this.totalItems
        }

        return lastItem
      },

      haveResults () {
        return this.totalItems > 0
      }


    },

    methods: {
      changePage (isActive, direction) {
        // only change the page if the button is active
        if (isActive) {
          const newPage = direction == 'next' ? this.currentPage + 1 : this.currentPage - 1

          this.$store.commit('updateRequestedPage', newPage)
          eventHub.$emit('getNewItems')
        }
      }
    }
  }
</script>
