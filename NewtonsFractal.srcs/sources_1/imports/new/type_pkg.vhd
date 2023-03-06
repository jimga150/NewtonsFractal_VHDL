library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use ieee.math_real.all;

package type_pkg is

    type t_std_logic_2d_arr is array(natural range<>, natural range<>) of std_logic;
        
    type t_double_arr is array(natural range<>) of std_logic_vector(63 downto 0);
    type t_double_2d_arr is array(natural range<>, natural range<>) of std_logic_vector(63 downto 0);
    
    type t_real_arr is array(natural range<>) of real;
    type t_real_2d_arr is array(natural range<>, natural range<>) of real;
    
    type t_int_arr is array(natural range<>) of integer;
    type t_int_2d_arr is array(natural range<>, natural range<>) of integer;
    type t_bool_arr is array(natural range<>) of boolean;
    
    pure function bool_to_std_logic(i_bool : boolean) return std_logic; 
    
    pure function int_max(
        i_int1 : integer;
        i_int2 : integer
    ) return integer;
    
    pure function int_min(
        i_int1 : integer;
        i_int2 : integer
    ) return integer;
    
    pure function barrel_decrement(
        i_int : integer;
        i_min : integer;
        i_max : integer
    ) return integer;
    
    pure function barrel_increment(
        i_int : integer;
        i_min : integer;
        i_max : integer
    ) return integer;
    
    --greatest possible double value without being inf or NaN
    constant c_double_max : std_logic_vector(63 downto 0) := x"7FEFFFFFFFFFFFFF";
    
    pure function parse_real_from_double(i_double : std_logic_vector(63 downto 0)) return real;
    
    pure function parse_double_from_real(i_real : real) return std_logic_vector;
    
    pure function negate_double(i_double : std_logic_vector(63 downto 0)) return std_logic_vector;
    
    pure function std_logic_to_real(i_std_logic : std_logic) return real;
    
    type t_prot_positive is protected
        impure function get return positive;
        procedure set (new_val : positive);
    end protected t_prot_positive;
    
    shared variable sv_seed1, sv_seed2 : t_prot_positive;
    
    impure function gen_random_slv(i_len : positive) return std_logic_vector;
    
end type_pkg;

package body type_pkg is

    type t_prot_positive is protected body
    
        variable v_pos : positive := 1;
        
        impure function get return positive is begin
            return v_pos;
        end function;
        
        procedure set(new_val : positive) is begin
            v_pos := new_val;
        end procedure;
    
    end protected body t_prot_positive;

    pure function bool_to_std_logic(i_bool : boolean) return std_logic is begin
        if (i_bool) then
            return '1';
        else
            return '0';
        end if;
    end function;
    
    pure function int_max(
        i_int1 : integer;
        i_int2 : integer
    ) return integer is
    
    begin
        if (i_int1 > i_int2) then
            return i_int1;
        end if;
        return i_int2;
    end function;
    
    pure function int_min(
        i_int1 : integer;
        i_int2 : integer
    ) return integer is
    
    begin
        if (i_int1 < i_int2) then
            return i_int1;
        end if;
        return i_int2;
    end function;
    
    pure function barrel_decrement(
        i_int : integer;
        i_min : integer;
        i_max : integer
    ) return integer is
        variable v_ans : integer := i_int-1;
    begin
        if i_int = i_min then
            v_ans := i_max;
        end if;
        return v_ans;
    end function;
    
    pure function barrel_increment(
        i_int : integer;
        i_min : integer;
        i_max : integer
    ) return integer is
        variable v_ans : integer := i_int+1;
    begin
        if i_int = i_max then
            v_ans := i_min;
        end if;
        return v_ans;
    end function;
    
    pure function parse_real_from_double(i_double : std_logic_vector(63 downto 0)) return real is
        variable v_sign : std_logic;
        variable v_exp : integer;
        variable v_mantissa : real;
        variable v_ans : real;
    begin
    
--        report "Function parse_real_from_double: i_double = 0x" & to_hstring(i_double) severity note;
    
        v_sign := i_double(63);
        v_exp := to_integer(unsigned(i_double(62 downto 52))) - 1023;
        
        if (v_exp = -1023) then
            --subnormal number
            v_mantissa := 0.0;
            v_exp := -1022;
        else
            v_mantissa := 1.0;
        end if;
        
        if (v_exp = 1024) then
--            report "Function parse_real_from_double: i_double (0x" & to_hstring(i_double) & ") is NaN (exponent is all 1s)" severity error;
            return -0.0;
        end if;
        
        for i in 1 to 52 loop
            v_mantissa := v_mantissa + std_logic_to_real(i_double(52 - i))*(real(2)**real(-i));
        end loop;
        
        v_ans := (real(2)**v_exp)*v_mantissa;
        
        if (v_sign = '1') then
            v_ans := -v_ans;
        end if;
        
--        report "Function parse_real_from_double: returning " & to_string(v_ans) severity note;
        
        return v_ans;
    
    end function;
    
    pure function parse_double_from_real(i_real : real) return std_logic_vector is
        
        variable v_real : real := i_real;
        variable v_sign : std_logic;
        variable v_exp : integer;
        variable v_subnormal : boolean;
        variable v_mantissa : std_logic_vector(51 downto 0);
        variable v_ans : std_logic_vector(63 downto 0);
    begin
    
--        report "Function parse_double_from_real: i_real = " & to_string(i_real) severity note;
        
        if (abs(i_real) = 0.0) then
            v_ans := (others => '0');
--            report "Function parse_double_from_real: returning 0x" & to_hstring(v_ans) severity note;
            return v_ans;
        end if;
    
        if (v_real < 0.0) then
            v_sign := '1';
            v_real := -v_real;
--            report "Function parse_double_from_real: input is negative, v_real is now " & to_string(i_real) severity note;
        else
            v_sign := '0';
--            report "Function parse_double_from_real: input is positive" severity note;
        end if;
        
        v_exp := integer(floor(log2(v_real)));
--        report "Function parse_double_from_real: v_exp is " & integer'image(v_exp) severity note;
        
        if (v_exp <= -1023) then
            v_exp := -1023;
            v_subnormal := true;
--            report "Function parse_double_from_real: input is subnormal, v_exp is now " & integer'image(v_exp) severity note;
        else
            v_subnormal := false;
        end if;
        
        v_real := v_real / (real(2)**real(v_exp));
--        report "Function parse_double_from_real: normalized v_real to exponent, v_real = " & to_string(v_real) severity note;
        
        assert v_real < 2.0 
--            report "Function parse_double_from_real: v_exp calculation is wrong. i_real = " & to_string(i_real) & ", v_exp = " & integer'image(v_exp) 
            severity failure;
        
        if (not v_subnormal) then
            v_real := v_real - 1.0;
--            report "Function parse_double_from_real: normalizing v_real to mantissa range, v_real is now " & to_string(v_real) severity note;
        else
--            report "Function parse_double_from_real: v_real is subnormal, v_real is still " & to_string(v_real) severity note;
        end if;
        
        for i in 1 to 52 loop
            if (v_real >= real(2)**real(-i)) then
                v_mantissa(52 - i) := '1';
                v_real := v_real - real(2)**real(-i);
            else
                v_mantissa(52 - i) := '0';
            end if;
        end loop;
        
        v_ans(63) := v_sign;
        v_ans(62 downto 52) := std_logic_vector(to_unsigned(v_exp + 1023, 11));
        v_ans(51 downto 0) := v_mantissa;
        
--        report "Function parse_double_from_real: returning 0x" & to_hstring(v_ans) severity note;
        
        return v_ans;
    
    end function;
    
    pure function negate_double(i_double : std_logic_vector(63 downto 0)) return std_logic_vector is
        variable v_ans : std_logic_vector(63 downto 0);
    begin
        v_ans := i_double;
        v_ans(63) := not v_ans(63);
        return v_ans;
    end function;
    
    pure function std_logic_to_real(i_std_logic : std_logic) return real is
        
    begin
        if (i_std_logic = '1') then
            return 1.0;
        else
            return 0.0;
        end if;
    end function;
    
    impure function gen_random_slv(i_len : positive) return std_logic_vector is
        
        variable v_seed1, v_seed2 : positive;
        variable v_rnd : real;
        constant c_rng_max_width : integer := 16; --max number of bits to generate per step
        
        variable v_idx_low, v_idx_high, v_data_width, v_max_data_val : natural;
        
        variable v_ans : std_logic_vector(i_len-1 downto 0);
        
    begin
        
        for j in 0 to integer(floor(real(v_ans'length)/real(c_rng_max_width))) loop
        
            v_seed1 := sv_seed1.get;
            v_seed2 := sv_seed2.get;
--            report "Generating random real, seed 1 = " & positive'image(v_seed1) & ", seed 2 = " & positive'image(v_seed2) severity note;
            
            uniform(v_seed1, v_seed2, v_rnd);
            
            sv_seed1.set(v_seed1);
            sv_seed2.set(v_seed2);
            
            v_idx_low := j*c_rng_max_width;
            v_idx_high := int_min((j+1)*c_rng_max_width - 1, v_ans'high);
            
            v_data_width := v_idx_high + 1 - v_idx_low;
            v_max_data_val := 2**v_data_width;
            
            v_ans(v_idx_high downto v_idx_low) := std_logic_vector(to_unsigned(integer(v_rnd*real(v_max_data_val)), v_data_width));
            
        end loop;
        
        return v_ans;
        
    end function;

end type_pkg;
