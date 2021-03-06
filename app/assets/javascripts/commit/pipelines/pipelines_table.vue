<script>
  import PipelinesService from '../../pipelines/services/pipelines_service';
  import PipelineStore from '../../pipelines/stores/pipelines_store';
  import pipelinesMixin from '../../pipelines/mixins/pipelines';

  export default {
    mixins: [
      pipelinesMixin,
    ],

    props: {
      endpoint: {
        type: String,
        required: true,
      },
      helpPagePath: {
        type: String,
        required: true,
      },
      autoDevopsHelpPath: {
        type: String,
        required: true,
      },
      emptyStateSvgPath: {
        type: String,
        required: true,
      },
      errorStateSvgPath: {
        type: String,
        required: true,
      },
      viewType: {
        type: String,
        required: false,
        default: 'child',
      },
    },

    data() {
      const store = new PipelineStore();

      return {
        store,
        state: store.state,
      };
    },

    computed: {
      /**
       * Empty state is only rendered if after the first request we receive no pipelines.
       *
       * @return {Boolean}
       */
      shouldRenderEmptyState() {
        return !this.state.pipelines.length &&
          !this.isLoading &&
          this.hasMadeRequest &&
          !this.hasError;
      },

      shouldRenderTable() {
        return !this.isLoading &&
          this.state.pipelines.length > 0 &&
          !this.hasError;
      },
    },
    created() {
      this.service = new PipelinesService(this.endpoint);
    },
    methods: {
      successCallback(resp) {
        return resp.json().then((response) => {
          // depending of the endpoint the response can either bring a `pipelines` key or not.
          const pipelines = response.pipelines || response;
          this.setCommonData(pipelines);

          const updatePipelinesEvent = new CustomEvent('update-pipelines-count', {
            detail: {
              pipelines: response,
            },
          });

          // notifiy to update the count in tabs
          if (this.$el.parentElement) {
            this.$el.parentElement.dispatchEvent(updatePipelinesEvent);
          }
        });
      },
    },
  };
</script>
<template>
  <div class="content-list pipelines">

    <loading-icon
      label="Loading pipelines"
      size="3"
      v-if="isLoading"
    />

    <empty-state
      v-if="shouldRenderEmptyState"
      :help-page-path="helpPagePath"
      :empty-state-svg-path="emptyStateSvgPath"
    />

    <error-state
      v-if="shouldRenderErrorState"
      :error-state-svg-path="errorStateSvgPath"
    />

    <div
      class="table-holder"
      v-if="shouldRenderTable"
    >
      <pipelines-table-component
        :pipelines="state.pipelines"
        :update-graph-dropdown="updateGraphDropdown"
        :auto-devops-help-path="autoDevopsHelpPath"
        :view-type="viewType"
      />
    </div>
  </div>
</template>
