class ContainersapiController < ApplicationController
  def get_container_pura
		@containers = Container.order('containernumber').where('deleted = false')
		count_container = @containers.count

		@containerlist = @containers.map do |c|
			{
				:id => c.id,
				:enabled => c.enabled,
				:containernumber => c.containernumber,
				:category => c.category,
				:vendor_id => c.vendor_id,
				:origin_company => 'Office PURA',
				:origin_id => c.id
			}
		end

		render json: {
			message: 'Success',
			status: 200,
			count: count_container,
			containers: @containerlist,
			}, status: 200
  end
end