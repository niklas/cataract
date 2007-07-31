require File.dirname(__FILE__) + '/../test_helper'
class BittornadoEaterTest < Test::Unit::TestCase
  def setup
    @eater = BittornadoEater.new('/dev/null')
  end
  # Replace this with your real tests.
  def test_truth
    assert true
  end

  def test_wolfram
    line = '"./WOLFRAM_RESEARCH_MATHEMATICA_V6_0_EDGEISO-_Demonoid_com_-[www.btmon.com].torrent": "seeding" (100.0%) - 0P0s0.000D u0.0K/s-d0.0K/s u26192K-d0K'
    t = @eater.match_torrent_entry(line)
    assert t
    assert_equal 'WOLFRAM_RESEARCH_MATHEMATICA_V6_0_EDGEISO-_Demonoid_com_-[www.btmon.com].torrent', t[:filename]
    assert_equal 'seeding', t[:statusmsg]
    assert_equal 100.0, t[:percent_done]
    assert_equal 0, t[:peers]
    assert_equal 0, t[:seeds]
    assert_equal 0.0, t[:distributed_copies]
    assert_equal 0.0, t[:rate_up]
    assert_equal 0.0, t[:rate_down]
    assert_equal 26192, t[:transferred_up]
    assert_equal 0, t[:transferred_down]
  end
end
