<template>
  <div class="tooltip">
    <div
      tabindex="0"
      :aria-describedby="id"
      :aria-expanded="isActive"
      @mouseenter="toggleTooltip(true)"
      @mouseleave="toggleTooltip(false)"
      v-touch="toggleTooltip"
      class="tooltip__trigger icon--info">
      <slot></slot>
    </div>
    <div role="tooltip" :id="id" v-show="isActive" class="tooltip__target">{{ text }}</div>
  </div>
</template>

<script>
  export default {
    name: 'tooltip',

    props: {
      text: {
        type: String,
        required: true
      }
    },

    data () {
      return {
        isActive: false,
        id: this._uid
      }
    },

    methods: {
      toggleTooltip (boolean) {
        this.isActive = typeof boolean == 'boolean' ? boolean : !this.isActive
      }
    },

    mounted () {      
      const tooltipTrigger = this.$el.querySelector('.tooltip__trigger')

      tooltipTrigger.addEventListener('blur', () => {
        this.toggleTooltip(false)
      })
      tooltipTrigger.addEventListener('focus', () => {
        this.toggleTooltip(true)
      })
    }
  }  
</script>