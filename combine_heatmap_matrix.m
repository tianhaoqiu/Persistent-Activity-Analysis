function[matrix_combined] = combine_heatmap_matrix(temp_matrix,m_number,varargin)

m_1 = NaN(size(temp_matrix));
m_2 = NaN(size(temp_matrix));
m_3 = NaN(size(temp_matrix));
m_4 = NaN(size(temp_matrix));

if (nargin == 3)
   temp_1 = varargin{1}; 
   for i = 1:size(temp_1, 1)
       for j = 1:size(temp_1, 2)
           if ~ isnan(temp_1(i,j))
               m_1(i,j) = temp_1(i,j);
           end
       end
   end
elseif (nargin == 4)
   temp_1 = varargin{1};
   for i = 1:size(temp_1, 1)
       for j = 1:size(temp_1, 2)
           if ~ isnan(temp_1(i,j))
               m_1(i,j) = temp_1(i,j);
           end
       end
   end
   temp_2 = varargin{2};
   for i = 1:size(temp_2, 1)
       for j = 1:size(temp_2, 2)
           if ~ isnan(temp_2(i,j))
               m_2(i,j) = temp_2(i,j);
           end
       end
   end
elseif (nargin == 5)
   temp_1 = varargin{1};
   for i = 1:size(temp_1, 1)
       for j = 1:size(temp_1, 2)
           if ~ isnan(temp_1(i,j))
               m_1(i,j) = temp_1(i,j);
           end
       end
   end
   temp_2 = varargin{2};
   for i = 1:size(temp_2, 1)
       for j = 1:size(temp_2, 2)
           if ~ isnan(temp_2(i,j))
               m_2(i,j) = temp_2(i,j);
           end
       end
   end
   temp_3 = varargin{3};
   for i = 1:size(temp_3, 1)
       for j = 1:size(temp_3, 2)
           if ~ isnan(temp_3(i,j))
               m_3(i,j) = temp_3(i,j);
           end
       end
   end
elseif (nargin == 6)
   temp_1 = varargin{1};
   for i = 1:size(temp_1, 1)
       for j = 1:size(temp_1, 2)
           if ~ isnan(temp_1(i,j))
               m_1(i,j) = temp_1(i,j);
           end
       end
   end
   temp_2 = varargin{2};
   for i = 1:size(temp_2, 1)
       for j = 1:size(temp_2, 2)
           if ~ isnan(temp_2(i,j))
               m_2(i,j) = temp_2(i,j);
           end
       end
   end
   temp_3 = varargin{3};
   for i = 1:size(temp_3, 1)
       for j = 1:size(temp_3, 2)
           if ~ isnan(temp_3(i,j))
               m_3(i,j) = temp_3(i,j);
           end
       end
   end
   temp_4 = varargin{4};
   for i = 1:size(temp_4, 1)
       for j = 1:size(temp_4, 2)
           if ~ isnan(temp_4(i,j))
               m_4(i,j) = temp_4(i,j);
           end
       end
   end
end

matrix_combined = temp_matrix;

if(m_number ==1 )
  for i = 1:size(matrix_combined,1)
        for j = 1:size(matrix_combined,2)
            if ~isnan(m_1(i,j))
                matrix_combined(i,j) = m_1(i,j);
            else
                matrix_combined(i,j) = NaN;
            end
          
        end
   end       
elseif(m_number ==2 )
    for i = 1:size(matrix_combined,1)
        for j = 1:size(matrix_combined,2)
            if ~isnan(m_1(i,j))  &&  ~isnan(m_2(i,j)) 
                matrix_combined(i,j) = (m_1(i,j) + m_2(i,j)) / m_number;
            elseif isnan(m_1(i,j)) && ~isnan(m_2(i,j)) 
                matrix_combined(i,j) = m_2(i,j);
            elseif ~isnan(m_1(i,j)) && isnan(m_2(i,j))
                matrix_combined(i,j) = m_1(i,j);
            else
                matrix_combined(i,j) = NaN;
            end
        end
    end    
elseif (m_number ==3 )
    for i = 1:size(matrix_combined,1)
        for j = 1:size(matrix_combined,2)
            if ~isnan(m_1(i,j))  &&  ~isnan(m_2(i,j)) && ~isnan(m_3(i,j))
                matrix_combined(i,j) = (m_1(i,j) + m_2(i,j) + m_3(i,j)) / m_number;
            elseif isnan(m_1(i,j))  &&  ~isnan(m_2(i,j)) && ~isnan(m_3(i,j))
                matrix_combined(i,j) =  (m_2(i,j) + m_3(i,j)) / (m_number - 1);
            elseif ~isnan(m_1(i,j))  &&  isnan(m_2(i,j)) && ~isnan(m_3(i,j))
                matrix_combined(i,j) =  (m_1(i,j) + m_3(i,j)) / (m_number - 1);
            elseif ~isnan(m_1(i,j))  &&  ~isnan(m_2(i,j)) && isnan(m_3(i,j))
                matrix_combined(i,j) =  (m_1(i,j) + m_2(i,j)) / (m_number - 1);
            elseif ~isnan(m_1(i,j))  &&  isnan(m_2(i,j)) && isnan(m_3(i,j))
                matrix_combined(i,j) =  m_1(i,j);
            elseif isnan(m_1(i,j))  &&  ~isnan(m_2(i,j)) && isnan(m_3(i,j))
                matrix_combined(i,j) =  m_2(i,j);
            elseif isnan(m_1(i,j))  &&  isnan(m_2(i,j)) && ~isnan(m_3(i,j))
                matrix_combined(i,j) =  m_3(i,j);
            else
                matrix_combined(i,j) = NaN;
            end
        end
    end    
elseif (m_number ==4 )
    for i = 1:size(matrix_combined,1)
        for j = 1:size(matrix_combined,2)
            if ~isnan(m_1(i,j))  &&  ~isnan(m_2(i,j)) && ~isnan(m_3(i,j)) && ~isnan(m_4(i,j))
                matrix_combined(i,j) = (m_1(i,j) + m_2(i,j) + m_3(i,j) +  m_4(i,j)) / m_number;
            elseif isnan(m_1(i,j))  &&  ~isnan(m_2(i,j)) && ~isnan(m_3(i,j)) && ~isnan(m_4(i,j))
                matrix_combined(i,j) = (m_2(i,j) + m_3(i,j) + m_4(i,j)) / (m_number - 1);
            elseif ~isnan(m_1(i,j))  &&  isnan(m_2(i,j)) && ~isnan(m_3(i,j)) && ~isnan(m_4(i,j))
                matrix_combined(i,j) = (m_1(i,j) + m_3(i,j) + m_4(i,j)) / (m_number - 1);
            elseif ~isnan(m_1(i,j))  &&  ~isnan(m_2(i,j)) && isnan(m_3(i,j)) && ~isnan(m_4(i,j))
                matrix_combined(i,j) = (m_1(i,j) + m_2(i,j) + m_4(i,j)) / (m_number - 1);
            elseif ~isnan(m_1(i,j))  &&  ~isnan(m_2(i,j)) && ~isnan(m_3(i,j)) && isnan(m_4(i,j))
                matrix_combined(i,j) = (m_1(i,j) + m_2(i,j) + m_3(i,j)) / (m_number - 1);
            elseif ~isnan(m_1(i,j))  &&  ~isnan(m_2(i,j)) && isnan(m_3(i,j)) && isnan(m_4(i,j))
                matrix_combined(i,j) = (m_1(i,j) + m_2(i,j)) / (m_number - 2);
            elseif ~isnan(m_1(i,j))  &&  isnan(m_2(i,j)) && ~isnan(m_3(i,j)) && isnan(m_4(i,j))
                matrix_combined(i,j) = (m_1(i,j) + m_3(i,j)) / (m_number - 2);
            elseif ~isnan(m_1(i,j))  &&  isnan(m_2(i,j)) && isnan(m_3(i,j)) && ~isnan(m_4(i,j))
                matrix_combined(i,j) = (m_1(i,j) + m_4(i,j)) / (m_number - 2);
            elseif isnan(m_1(i,j))  &&  ~isnan(m_2(i,j)) && ~isnan(m_3(i,j)) && isnan(m_4(i,j))
                matrix_combined(i,j) = (m_2(i,j) + m_3(i,j)) / (m_number - 2);
            elseif isnan(m_1(i,j))  &&  ~isnan(m_2(i,j)) && isnan(m_3(i,j)) && ~isnan(m_4(i,j))
                matrix_combined(i,j) = (m_2(i,j) + m_4(i,j)) / (m_number - 2);
            elseif isnan(m_1(i,j))  &&  isnan(m_2(i,j)) && ~isnan(m_3(i,j)) && ~isnan(m_4(i,j))
                matrix_combined(i,j) = (m_3(i,j) + m_4(i,j)) / (m_number - 2);
            elseif ~isnan(m_1(i,j))  &&  isnan(m_2(i,j)) && isnan(m_3(i,j)) && isnan(m_4(i,j))
                matrix_combined(i,j) =  m_1(i,j);
            elseif isnan(m_1(i,j))  &&  ~isnan(m_2(i,j)) && isnan(m_3(i,j)) && isnan(m_4(i,j))
                matrix_combined(i,j) =  m_2(i,j);
            elseif isnan(m_1(i,j))  &&  isnan(m_2(i,j)) && ~isnan(m_3(i,j)) && isnan(m_4(i,j))
                matrix_combined(i,j) =  m_3(i,j);
            elseif isnan(m_1(i,j))  &&  isnan(m_2(i,j)) && isnan(m_3(i,j)) && ~isnan(m_4(i,j))
                matrix_combined(i,j) =  m_4(i,j);
            else
                matrix_combined(i,j) = NaN;
            end       
        end
    end    
end




end


